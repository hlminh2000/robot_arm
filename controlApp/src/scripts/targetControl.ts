import { Matrix, Plane, PointerEventTypes, Scene, Vector2, Vector3 } from "@babylonjs/core";
import { Mesh } from "@babylonjs/core/Meshes/mesh";

const castScenePointerRay = (scene: Scene, scenePoint: Vector2, plane: Plane) => {
    const ray = scene.createPickingRay(scenePoint.x, scenePoint.y, Matrix.Identity(), scene.activeCamera);
    const movingPlane = plane;
    const distance = ray.intersectsPlane(movingPlane);
    const worldPoint = ray.origin.add(ray.direction.scale(distance));
    return worldPoint
}
export default class TargetControl {
    private scenePointerDownNormal: Vector3 | null;

    public constructor(public mesh: Mesh) {
    }

    public onStart(): void {
        const scene = this.mesh.getScene();
        scene.onPointerObservable.add((pointerInfo) => {
            ({
                [PointerEventTypes.POINTERDOWN]: () => {
                    const pickResult = pointerInfo.pickInfo;
                    if(pickResult?.pickedMesh === this.mesh) return;
                    scene.activeCamera.detachControl();
                    this.scenePointerDownNormal = this.mesh.getFacetNormal(pickResult.faceId);
                },
                [PointerEventTypes.POINTERUP]: () => {
                    scene.activeCamera.attachControl();
                    this.scenePointerDownNormal = null;
                },
                [PointerEventTypes.POINTERMOVE]: () => {
                    if (!this.scenePointerDownNormal) return;
                    const scenePointerDown = new Vector2(scene.pointerX, scene.pointerY);
                    const movingPlane = Plane.FromPositionAndNormal(this.mesh.position, this.scenePointerDownNormal);
                    this.mesh.position = castScenePointerRay(scene, scenePointerDown, movingPlane);
                }
            } as const)[pointerInfo.type]?.();
        })
    }

    public onUpdate(): void {
    }

}
