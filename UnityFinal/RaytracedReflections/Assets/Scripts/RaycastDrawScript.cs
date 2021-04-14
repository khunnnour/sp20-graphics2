using UnityEngine;

public class RaycastDrawScript : MonoBehaviour
{
	public Cubemap skybox;
	public Texture2D refTex;
	public bool randomRays;
	public float rayLength = 10.0f;
	public int raysPerFrame = 50;

	private Camera _cam;
	private Vector2 _screenDim;
	private Vector2 _hitTexCoord;
	private Vector3 _rayOrigin;
	private float _pixelOffsetX, _pixelOffsetY;
	private int _totRays, _rayIndex, _lastIndex;

	// Start is called before the first frame update
	void Start()
	{
		_cam = GameObject.FindObjectOfType<Camera>();

		_pixelOffsetX = 0f;
		_pixelOffsetY = 0f;

		_screenDim = new Vector2(_cam.pixelWidth, _cam.pixelHeight);

		_rayOrigin = _cam.gameObject.transform.position;

		_totRays = refTex.width * refTex.height;
		_rayIndex = 0;
		_lastIndex = 0;
	}

	// Update is called once per frame
	void Update()
	{
		// update ray origin
		_rayOrigin = _cam.gameObject.transform.position;

		// cast the rays
		CastAllRays();
	}

	private void CastAllRays()
	{
		if (randomRays)
		{
			for (int i = 0; i < raysPerFrame; i++)
				CastRngRay(i);
		}
		else
		{
			int loopEnd = _lastIndex + raysPerFrame;
			if (loopEnd > _totRays) loopEnd = _totRays;

			for (_rayIndex = _lastIndex; _rayIndex < loopEnd; _rayIndex++)
				CastRay(_rayIndex);

			if (loopEnd == _totRays)
			{
				_lastIndex = 0;
				// for offsetting the ray line to pickup missed pixels
				//pixelOffset += 0.5f;
				//if (pixelOffset > 2f) pixelOffset = -2f;
			}
			else _lastIndex = loopEnd;
		}
	}

	// Cast ray based on set rays
	private void CastRay(int index)
	{
		// Get point from index
		Vector2 point = IndexToPoint(index);
		// Turn into a uv
		point.x *= 1f / refTex.width;
		point.y *= 1f / refTex.height;

		// Get random offset
		_pixelOffsetX = Random.Range(-2f, 2f);
		_pixelOffsetY = Random.Range(-2f, 2f);

		// make screen coordinate out of uv
		Vector3 screenPt = new Vector3(point.x * _screenDim.x + _pixelOffsetX, point.y * _screenDim.y + _pixelOffsetY, 1f);
		// turn screen point into a world point
		Vector3 aimPoint = _cam.ScreenToWorldPoint(screenPt);

		// Get ray dir
		Vector3 rayDir = (aimPoint - _rayOrigin).normalized;

		// Cast ray
		Ray cast = new Ray(_rayOrigin, rayDir * rayLength);
		RaycastHit hit;
		Physics.Raycast(cast, out hit);

		Debug.DrawRay(_rayOrigin, rayDir * rayLength, Color.green);

		// If hit: bounce
		if (hit.collider)
		{
			// Get reflectiveness
			//Color reflectCol = GetHitRelfectiveness(hit);
			//float reflect = reflectCol.r;
			float reflect = 1f;
			Debug.Log("Reflective: " + reflect.ToString("F2"));

			if (reflect > 0f)
			{
				_hitTexCoord = hit.textureCoord;
				CastBounce(cast, hit, reflect);
			}
		}
	}

	// Cast random ray
	private void CastRngRay(int index)
	{
		// Get pixel coordinates
		float screenX, screenY;
		if (index == 0)
		{
			// if the first ray, make it center
			screenX = _screenDim.x / 2f;
			screenY = _screenDim.y / 2f;
		}
		else
		{
			// else get a random one
			screenX = Random.Range(-2f, _screenDim.x+2f);
			screenY = Random.Range(-2f, _screenDim.y+2f);
		}

		// make screen coordinate and turn to a world coordinate
		Vector3 screenPt = new Vector3(screenX, screenY, 1f);
		Vector3 aimPoint = _cam.ScreenToWorldPoint(screenPt);

		//Debug.Log(aimPoint.ToString("F3"));

		// Get ray dir
		Vector3 rayDir = (aimPoint - _rayOrigin).normalized;

		// Cast ray
		Ray cast = new Ray(_rayOrigin, rayDir * rayLength);
		RaycastHit hit;
		Physics.Raycast(cast, out hit);

		Debug.DrawRay(_rayOrigin, rayDir * rayLength, Color.green);

		// If hit: bounce
		if (hit.collider)
		{
			// Get reflectiveness
			//Color reflectCol = GetHitRelfectiveness(hit);
			//float reflect = reflectCol.r;
			float reflect = 1f;
			//Debug.Log("Reflective: " + reflect.ToString("F2"));

			//if (reflect > 0f)
			if (hit.collider.CompareTag("refl"))
			{
				_hitTexCoord = hit.textureCoord;
				CastBounce(cast, hit, reflect);
			}
		}
	}

	private void CastBounce(Ray ray, RaycastHit hit, float reflect)
	{
		Color color;

		Vector3 reflected = Vector3.Reflect(ray.direction, hit.normal);

		Debug.DrawRay(hit.point, reflected * rayLength * reflect , Color.red);
		if (Physics.Raycast(hit.point, reflected * rayLength * reflect, out hit))
		{
			// Output color found
			color = GetHitColor(hit);
			//Debug.Log(color);
		}
		else
		{
			// hit nothing (skybox?)
			//color = defaultCol;
			color = SampleSkyBox(reflected.normalized);
		}

		refTex.SetPixel((int)(_hitTexCoord.x * refTex.width), (int)(_hitTexCoord.y * refTex.height), color);
		refTex.Apply();
	}

	// Get objects reflectiveness at ray hit point
	/*private Color GetHitRelfectiveness(RaycastHit hit)
	{
		// Get renderer and its material
		Renderer renderer = hit.collider.GetComponent<MeshRenderer>();
		Texture2D specularMap = renderer.material.GetTexture("_SpecTex") as Texture2D;

		// get texcoord that was hit
		Vector2 pCoord = hit.textureCoord;
		pCoord.x *= specularMap.width;
		pCoord.y *= specularMap.height;
		//Debug.Log(pCoord.ToString("F3"));

		// compensate for tiling and get the texture color
		Vector2 tiling = renderer.material.mainTextureScale;
		Color color = specularMap.GetPixel(Mathf.FloorToInt(pCoord.x * tiling.x), Mathf.FloorToInt(pCoord.y * tiling.y));

		// Return color found
		return color;
	}*/

	// Get objects color at ray hit point
	private Color GetHitColor(RaycastHit hit)
	{
		// Get renderer and its material
		Renderer component = hit.collider.GetComponent<MeshRenderer>();
		Texture2D texture2D = component.material.mainTexture as Texture2D;

		// get texcoord that was hit
		Vector2 pCoord = hit.textureCoord;
		pCoord.x *= texture2D.width;
		pCoord.y *= texture2D.height;
		//Debug.Log(pCoord.ToString("F3"));

		// compensate for tiling and get the texture color
		Vector2 tiling = component.material.mainTextureScale;
		Color color = texture2D.GetPixel(Mathf.FloorToInt(pCoord.x * tiling.x), Mathf.FloorToInt(pCoord.y * tiling.y));

		// Return color found
		return color;
	}

	private Color SampleSkyBox(Vector3 v)
	{
		// Get face index / uv 
		Vector3 vAbs = new Vector3(Mathf.Abs(v.x), Mathf.Abs(v.y), Mathf.Abs(v.z));
		float ma;
		int faceIndex;
		Vector2 uv;

		// if pointing in z-dirs
		if (vAbs.z >= vAbs.x && vAbs.z >= vAbs.y)
		{
			faceIndex = v.z < 0.0f ? 5 : 4;
			ma = 0.5f / vAbs.z;
			uv = new Vector2(v.z < 0.0f ? -v.x : v.x, -v.y);
		}
		// now see if looking in y-dir
		else if (vAbs.y >= vAbs.x)
		{
			faceIndex = v.y < 0.0f ? 3 : 2;
			ma = 0.5f / vAbs.y;
			uv = new Vector2(v.x, v.y < 0.0f ? -v.z : v.z);
		}
		// must be looking in x-dir
		else
		{
			// if act vec3 is -x, then pointing in -x direction
			faceIndex = v.x < 0.0f ? 1 : 0;
			ma = 0.5f / vAbs.x;
			uv = new Vector2(v.x < 0.0f ? v.z : -v.z, -v.y);
		}
		uv *= ma;
		uv += new Vector2(0.5f, 0.5f);

		// Get cubemap face from faceIndex
		CubemapFace face;
		switch (faceIndex)
		{
			case 0:
				face = CubemapFace.NegativeX;
				break;
			case 1:
				face = CubemapFace.PositiveX;
				break;
			case 2:
				face = CubemapFace.PositiveY;
				break;
			case 3:
				face = CubemapFace.NegativeY;
				break;
			case 4:
				face = CubemapFace.NegativeZ;
				break;
			case 5:
				face = CubemapFace.PositiveZ;
				break;
			default:
				face = CubemapFace.PositiveY;
				break;
		}

		return skybox.GetPixel(face, (int)(uv.x * skybox.width * 0.25f), (int)(uv.y * skybox.width * 0.25f));
	}

	Vector2 IndexToPoint(int index)
	{
		int acc = index, y = 0;
		while (acc > refTex.width)
		{
			acc -= refTex.width;
			y++;
		}

		return new Vector2(acc, y);
	}
	int PointToIndex(Vector2 point)
	{
		return (int)(point.x) + (int)(point.y) * refTex.width;
	}
}
