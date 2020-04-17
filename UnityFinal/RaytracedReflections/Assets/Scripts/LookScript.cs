using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LookScript : MonoBehaviour
{
	[Range(0.1f, 1.0f)]
	public float sensitivty = 1.0f;

	private bool dragging;
	private Vector3 dragOrigin, dragStop;

	// Start is called before the first frame update
	void Start()
	{
		dragging = false;
		dragOrigin = Vector3.zero;
		dragStop = Vector3.zero;
	}

	// Update is called once per frame
	void Update()
	{
		GetInput();

		if (dragging)
		{
			Drag();
		}
	}

	private void Drag()
	{
		Vector3 currPos = Input.mousePosition;

		Vector3 change = (dragOrigin - currPos) * (sensitivty * -0.4f);

		Vector3 newAngles = transform.rotation.eulerAngles;
		newAngles.x -= change.y;
		newAngles.y += change.x;
		newAngles.z = 0f;

		transform.rotation = Quaternion.Euler(newAngles);

		dragOrigin = Input.mousePosition;
	}

	private void GetInput()
	{
		if (Input.GetKeyDown(KeyCode.Mouse0))
		{
			dragging = true;
			dragOrigin = Input.mousePosition;
		}

		if (Input.GetKeyUp(KeyCode.Mouse0))
		{
			dragging = false;
		}
	}
}