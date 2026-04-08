uniform sampler2D texture;

// arrays of colors to swap
uniform vec4 oldColors[4];   // up to 3 old colors
uniform vec4 newColors[4];   // their replacements

void main()
{
    vec4 texColor = texture2D(texture, gl_TexCoord[0].xy);

    // loop through all defined swaps
    for (int i = 0; i < 4; i++) {
        if (distance(texColor.rgb, oldColors[i].rgb) < 0.01) {
            gl_FragColor = vec4(newColors[i].rgb, texColor.a);
            return;
        }
    }

    // if no match, keep original
    gl_FragColor = texColor;
}
