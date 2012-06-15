package away3d.core.raycast.colliders.triangles
{

	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Object3D;
	import away3d.core.raycast.colliders.*;
	import away3d.entities.Mesh;

	public class MeshRayCollider extends RayColliderBase
	{
		private var _subMeshCollider:SubMeshRayColliderBase;

		public function MeshRayCollider( subMeshCollider:SubMeshRayColliderBase ) {
			super();
			_subMeshCollider = subMeshCollider;
		}

		override public function evaluate():void {
			reset();
			evaluateObject3D( _entities[ 0 ] );
		}

		private function evaluateObject3D( object3d:Object3D ):void {

			var i:uint, len:uint;
			var container:ObjectContainer3D;

			// Sweep children and sub-meshes.
			if( object3d is ObjectContainer3D ) {

				// Evaluate mesh sub-meshes.
				if( object3d is Mesh ) {
					var mesh:Mesh = object3d as Mesh;
					_subMeshCollider.entity = mesh;
					// Transform ray to mesh's object space.
					_subMeshCollider.updateRay(
						mesh.inverseSceneTransform.transformVector( _rayPosition ),
						mesh.inverseSceneTransform.deltaTransformVector( _rayDirection )
					);
					len = mesh.subMeshes.length;
					for( i = 0; i < len; i++ ) {
						_subMeshCollider.subMesh = mesh.subMeshes[ i ];
						_subMeshCollider.evaluate();
						if( _subMeshCollider.aCollisionExists ) {
							_aCollisionExists = true;
							_collisionData = _subMeshCollider.collisionData;
							return;
						}
					}
				}

				// Evaluate container children.
				container = object3d as ObjectContainer3D;
				len = container.numChildren;
				for( i = 0; i < len; i++ ) {
					if( !_aCollisionExists ) {
						evaluateObject3D( container.getChildAt( i ) );
					}
				}
			}
		}
	}
}
