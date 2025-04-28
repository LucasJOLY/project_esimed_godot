shader_type canvas_item;

uniform float amount: hint_range(0.0, 5.0);
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;



void fragment() {
	COLOR.rgb = textureLod(SCREEN_TEXTURE, SCREEN_UV, amount).rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
