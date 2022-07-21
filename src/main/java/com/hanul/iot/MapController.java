package com.hanul.iot;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class MapController {
	@GetMapping("/list.map")
	public String map() {
		return "map";
	}

}
