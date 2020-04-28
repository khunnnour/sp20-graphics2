using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RaycastTestScript : MonoBehaviour
{
	public int bounces = 1;
	public int rayCount = 1;
	public float raySegmentLength = 10.0f;

	private Camera cam;
	private Vector2 screenDim;
	private Vector3 rayOrigin;

	// Start is called before the first frame update
	void Start()
	{
		cam = GameObject.FindObjectOfType<Camera>();

		screenDim = new Vector2(cam.pixelWidth, cam.pixelHeight);

		rayOrigin = cam.gameObject.transform.position;
	}

	// Update is called once per frame
	void Update()
	{
		CastAllRays();
	}

	private void CastAllRays()
	{
		for (int i = 0; i < rayCount; i++)
			CastRay(i);
	}

	private void CastRay(int index)
	{
		// Get pixel coordinates
		float screenX, screenY;
		if (index == 0)
		{
			// if the first ray, make it center
			screenX = screenDim.x / 2f;
			screenY = screenDim.y / 2f;
		}
		else
		{
			// else get a random one
			screenX = UnityEngine.Random.Range(0f, screenDim.x);
			screenY = UnityEngine.Random.Range(0f, screenDim.y);
		}

		// make screen coordinate and turn to a world coordinate
		Vector3 screenPt = new Vector3(screenX, screenY, 1f);
		Vector3 aimPoint = cam.ScreenToWorldPoint(screenPt);

		//Debug.Log(aimPoint.ToString("F3"));

		// Get ray dir
		Vector3 rayDir = (aimPoint - rayOrigin).normalized;

		// Cast ray
		Ray cast = new Ray(rayOrigin, rayDir * raySegmentLength);
		RaycastHit hit;
		Physics.Raycast(cast, out hit);

		Debug.DrawRay(rayOrigin, rayDir * raySegmentLength, Color.green);

		// If hit: bounce
		if (hit.collider)
			CastBounce(cast, hit);
	}

	private void CastBounce(Ray ray, RaycastHit hit)
	{
		Vector3 reflected = Vector3.Reflect(ray.direction, hit.normal);

		Debug.DrawRay(hit.point, reflected * raySegmentLength, Color.red);
	}
}