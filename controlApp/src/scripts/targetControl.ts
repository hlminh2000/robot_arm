import { AbstractMesh, Matrix, Plane, PointerEventTypes, Scene, Vector2, Vector3 } from "@babylonjs/core";
import { Mesh } from "@babylonjs/core/Meshes/mesh";

export default class MyScriptComponent {
    private scenePointerDownNormal: Vector3 | null;

    public constructor(public mesh: Mesh) {
    }

    public onStart(): void {

        const scene = this.mesh.getScene();
        scene.onPointerObservable.add((pointerInfo) => {
            ({
                [PointerEventTypes.POINTERDOWN]: () => {
                    const pickResult = pointerInfo.pickInfo;
                    if (pickResult.hit && pickResult.pickedMesh === this.mesh) {
                        scene.activeCamera.detachControl();
                        this.scenePointerDownNormal = this.mesh.getFacetNormal(pickResult.faceId);
                    }
                },
                [PointerEventTypes.POINTERUP]: () => {
                    scene.activeCamera.attachControl();
                    this.scenePointerDownNormal = null;
                },
                [PointerEventTypes.POINTERMOVE]: () => {
                    if (!this.scenePointerDownNormal) return;
                    
                    const movingPlane = Plane.FromPositionAndNormal(this.mesh.position, this.scenePointerDownNormal);
                    const worldPoint = this.castScenePointerRay(scene, new Vector2(scene.pointerX, scene.pointerY), movingPlane);

                    this.mesh.position.x = worldPoint.x;
                    this.mesh.position.y = worldPoint.y;
                    this.mesh.position.z = worldPoint.z;

                }
            } as const)[pointerInfo.type]?.();
        })
    }

    private castScenePointerRay(scene:Scene, scenePoint: Vector2, plane: Plane) {
        const ray = scene.createPickingRay(scenePoint.x, scenePoint.y, Matrix.Identity(), scene.activeCamera);
        const movingPlane = plane;
        const distance = ray.intersectsPlane(movingPlane);
        const worldPoint = ray.origin.add(ray.direction.scale(distance));
        return worldPoint
    }

    public onUpdate(): void {
    }

}
