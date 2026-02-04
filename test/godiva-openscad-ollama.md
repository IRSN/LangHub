# Godiva Device OpenSCAD - Ollama

This test generates OpenSCAD models using Ollama.

## Ollama Generation

```scad
// Godiva Device OpenSCAD Script

// Parameters for parametric design
$fn = 50; // Number of facets for smooth edges

module core_assembly() {
    // Core Assembly Dimensions
    length = 150;
    width = 100;
    height = 50;

    difference() {
        cube([length, width, height], center=true);
        cylinder(r=3.5, h=height+2, center=false) + translate([-4, -4, 0]) cylinder(r=3.5, h=height+2, center=false); // Mounting holes
    }
}

module housing_shell() {
    // Housing Dimensions
    internal_length = core_assembly.length + 10;
    internal_width = core_assembly.width + 10;
    internal_height = core_assembly.height + 10;
    
    wall_thickness = 2.5;

    difference() {
        cube([internal_length, internal_width, internal_height], center=true);
        translate([-wall_thickness/2, -wall_thickness/2, -wall_thickness/2]) cube([internal_length + wall_thickness, internal_width + wall_thickness, internal_height + wall_thickness], center=false); // Housing shell
        translate([-wall_thickness, -wall_thickness, -wall_thickness]) cylinder(r=5, h=internal_height+10, center=true); // Ventilation holes
    }

    for (x=[-2.5, 7.5]) {
        for (y=[-2.5, 4.5]) {
            translate([x, y, -wall_thickness/2]) cylinder(r=5, h=10, center=false);
        }
    }

    // Base Mounting Holes
    translate([-wall_thickness/2, -wall_thickness/2, -wall_thickness/2]) cube([internal_length + wall_thickness, internal_width + wall_thickness, wall_thickness], center=false);
}

module control_interface_panel() {
    // Panel Dimensions
    length = 100;
    width = 60;
    height = 3;

    difference() {
        cube([length, width, height], center=true);
        cylinder(r=6, h=height+2, center=false) + translate([-4, -4, 0]) cylinder(r=6, h=height+2, center=false); // Button cutouts
        cylinder(r=3, h=height+2, center=false) + translate([50, 30, 0]) cylinder(r=3, h=height+2, center=false); // LED indicator holes
        translate([-length/2, -width/2, height-1.5]) cube([length, width, 3], center=false); // Display cutout
    }

    // Text for display
    translate([20, 20, 1.5]) text("DISPLAY", size=3);
}

module final_assembly() {
    difference() {
        housing_shell();
        core_assembly() + translate([-75, -50, 0]);
        control_interface_panel() + translate([70, -45, 0]);
    }
}

// Render the final assembly
final_assembly();
```

