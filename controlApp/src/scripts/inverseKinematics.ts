import { Mesh } from "@babylonjs/core/Meshes/mesh";
import TargetControl from './targetControl';
import { AbstractMesh, Tools, Vector3 } from "@babylonjs/core";
import z from 'zod';
import JointControl from "./jointControl";

const RobotArmPartMetadataSchema = z.object({
    partType: z.union([
        z.literal('joint'), 
        z.literal('arm') 
    ]).nonoptional(),
});

export default class InverseKinematicsControl {    

    private joints: AbstractMesh[];
    private arms: AbstractMesh[];

    public constructor(public mesh: Mesh) {
        const { arms, joints } = InverseKinematicsControl.getJointsAndArms(mesh);
        this.arms = arms;
        this.joints = joints;
        console.log(this.arms);
        console.log(this.joints);
    }

    public onStart(): void {
        TargetControl.targetControlPositionObs.add(this.onTargetMove);
    }

    public onUpdate(): void {
    }

    private onTargetMove(targetPosition: Vector3) {
        const { jointAngleDegs } = this.inverseKinematics(targetPosition);
        this.joints.forEach((joint) => {
            const jointAngleDeg = jointAngleDegs[this.joints.indexOf(joint)];
            if (!jointAngleDeg) return;
            joint.rotation.z = Tools.ToRadians(jointAngleDeg);
            JointControl.jointAngleObs.notifyObservers({jointMesh: joint});
        })
    }

    private inverseKinematics(target: Vector3): {
        jointAngleDegs: number[],
    } {
        return {
            jointAngleDegs: []
        }
    }

    static getJointsAndArms(mesh: AbstractMesh, acc = {
        joints: [] as AbstractMesh[],
        arms: [] as AbstractMesh[]
    }) {
        const metaData = RobotArmPartMetadataSchema.parse(mesh.metadata.customMetadata);
        if (metaData.partType === 'arm') {
            acc.arms.push(mesh);
        } else {
            acc.joints.push(mesh);
        }
        const nextPartMesh = mesh.getChildMeshes().find(m => {
            const _metadata = RobotArmPartMetadataSchema.safeParse(m.metadata.customMetadata).data;
            return metaData.partType !== _metadata.partType
        });
        nextPartMesh && InverseKinematicsControl.getJointsAndArms(nextPartMesh, acc);
        return acc;
    }
}
