import { Mesh } from "@babylonjs/core/Meshes/mesh";
import { AbstractMesh, ActionManager, Matrix, PointerEventTypes, Tools, Vector2, Vector3, Viewport } from "@babylonjs/core";

function getSignedAngleRad(vecA: Vector2, vecB: Vector2): number {
    const dot = vecA.x * vecB.x + vecA.y * vecB.y;
    const cross = vecA.x * vecB.y - vecA.y * vecB.x;
    // Returns angle in radians
    return Math.atan2(cross, dot);
}

export default class JointControl {
    private jointMesh: Mesh;

    private isMoving: boolean = false;

    private currentJointAngle = 0;
    private lastJointAngle = 0;

    private scenePointerDown: Vector2 | null = null;

    public constructor(public mesh: Mesh) {
        this.jointMesh = mesh;
        this.currentJointAngle = Tools.ToDegrees(this.jointMesh.rotation.z);
        this.lastJointAngle = this.currentJointAngle;
    }

    public onStart(): void {
        const arm = this.jointMesh.getChildMeshes().find((m) => m.name === "Arm");

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
                    if (this.isMoving) {
                        const projectedJointPosition = Vector3.Project(
                            this.jointMesh.getAbsolutePivotPoint(),
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

                        if (nextJointAngle > 90) {
                            this.setJointAngle(90);
                        } else if (nextJointAngle < -90) {
                            this.setJointAngle(-90);
                        } else{
                            this.setJointAngle(nextJointAngle)
                        }
                    }
                }
            } as const)[pointerInfo.type]?.();
        });
    }

    private setJointAngle(deg: number) {
        this.currentJointAngle = deg;
        this.jointMesh.rotation.z = Tools.ToRadians(deg);
    }

    public onUpdate(): void {
        // this.mesh.rotation.y += 0.04 * this.mesh.getScene().getAnimationRatio();
    }

    static ensureActionManager(mesh: AbstractMesh): void {
        if (!mesh.actionManager) {
            mesh.actionManager = new ActionManager(mesh.getScene());
        }
    }
}
