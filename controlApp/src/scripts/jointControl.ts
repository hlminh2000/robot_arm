import { Mesh } from "@babylonjs/core/Meshes/mesh";
import { AbstractMesh, Matrix, Observable, PointerEventTypes, Tools, Vector2, Vector3, Viewport } from "@babylonjs/core";

function getSignedAngleRad(vecA: Vector2, vecB: Vector2): number {
    const dot = vecA.x * vecB.x + vecA.y * vecB.y;
    const cross = vecA.x * vecB.y - vecA.y * vecB.x;
    // Returns angle in radians
    return Math.atan2(cross, dot);
}

const clamp = (value: number, min: number, max: number) => (
    Math.min(Math.max(value, min), max)
)

export default class JointControl {
    private isMoving: boolean = false;

    private currentJointAngle = 0;
    private lastJointAngle = 0;

    private scenePointerDown: Vector2 | null = null;

    static jointAngleObs = new Observable<{jointMesh: AbstractMesh}>()

    public constructor(public mesh: Mesh) {
        this.currentJointAngle = Tools.ToDegrees(this.mesh.rotation.z);
        this.lastJointAngle = this.currentJointAngle;
    }

    public onStart(): void {
        const arm = this.mesh.getChildMeshes().find((m) => m.name === "Arm");
        
        JointControl.jointAngleObs.add(({jointMesh}) => {
            if (jointMesh === this.mesh) {
                this.setJointAngle(Tools.ToDegrees(jointMesh.rotation.z));
            }
        })

        const scene = arm.getScene();

        scene.onPointerObservable.add((pointerInfo) => {
            ({ 
                [PointerEventTypes.POINTERDOWN]: () => {
                    const pickResult = pointerInfo.pickInfo;
                    if (pickResult?.hit && pickResult.pickedMesh === arm) {
                        this.isMoving = true;
                        scene.activeCamera.detachControl();
                        this.scenePointerDown = new Vector2(scene.pointerX, scene.pointerY);
                    }
                },
                [PointerEventTypes.POINTERUP]: () => {
                    this.isMoving = false;
                    this.scenePointerDown = null;
                    scene.activeCamera.attachControl();
                    this.lastJointAngle = this.currentJointAngle;
                },
                [PointerEventTypes.POINTERMOVE]: () => {
                    if (!this.isMoving) {
                        return;
                    }
                    const projectedJointPosition = Vector3.Project(
                        this.mesh.getAbsolutePivotPoint(),
                        Matrix.Identity(),
                        scene.getTransformMatrix(),
                        new Viewport(0, 0, 1, 1).toGlobal(
                            scene.getEngine().getRenderingCanvas().width,
                            scene.getEngine().getRenderingCanvas().height,
                        )
                    )
                    const projectedJointPosition2D = new Vector2(
                        projectedJointPosition.x,
                        projectedJointPosition.y,
                    )
                    const pointerDownVector = this.scenePointerDown.subtract(projectedJointPosition2D);
                    const currentPointerVector = new Vector2(scene.pointerX, scene.pointerY).subtract(projectedJointPosition2D);
                    const deltaAngle = Tools.ToDegrees(getSignedAngleRad(currentPointerVector, pointerDownVector));
                    const nextJointAngle = this.lastJointAngle + deltaAngle;

                    /** Prevent sudden swings */
                    if (Math.abs(nextJointAngle - this.currentJointAngle) > 45) return;

                    this.setJointAngle(clamp(nextJointAngle, -90, 90));

                }
            } as const)[pointerInfo.type]?.();
        });
    }

    private setJointAngle(deg: number) {
        this.currentJointAngle = deg;
        this.mesh.rotation.z = Tools.ToRadians(deg);
        window.electron.send('send-to-arduino', JSON.stringify({
            joint: this.mesh.name,
            angle: deg + 90,
        }));
    }

    public onUpdate(): void {}
}
