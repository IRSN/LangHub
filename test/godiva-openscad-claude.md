# Godiva Device OpenSCAD - Claude

This test generates OpenSCAD models using Claude.

## Claude Generation

Perfect! Now I have the technical specifications. Let me generate the complete OpenSCAD script for the Godiva device based on these specifications:

```openscad
// ============================================================================
// GODIVA DEVICE - COMPLETE OPENSCAD PARAMETRIC DESIGN
// ============================================================================
// A compact modular system with three main components:
// 1. Core Assembly - Central processing and power unit
// 2. Housing/Shell - Protective enclosure with thermal management
// 3. Control Interface Panel - User interaction and status display
// ============================================================================

// Global Parameters
// ============================================================================
$fn = 50;  // Fragments for smooth circles (increase for production)

// Core Assembly Parameters
CORE_LENGTH = 150;          // mm
CORE_WIDTH = 100;           // mm
CORE_HEIGHT = 50;           // mm
CORE_WALL = 3;              // mm
CORE_MOUNT_HOLE_DIA = 4;    // mm (M4)
CORE_MOUNT_X = 140;         // mm center-to-center spacing
CORE_MOUNT_Y = 90;          // mm center-to-center spacing

// Housing/Shell Parameters
HOUSING_CLEARANCE = 5;      // mm around core assembly
HOUSING_LENGTH = 165;       // mm
HOUSING_WIDTH = 115;        // mm
HOUSING_HEIGHT = 70;        // mm
HOUSING_WALL = 2.5;         // mm
VENT_HOLE_DIA = 6;          // mm
VENT_HOLE_SPACING = 10;     // mm
HOUSING_MOUNT_HOLE_DIA = 5; // mm (M5)

// Control Panel Parameters
PANEL_LENGTH = 100;         // mm
PANEL_WIDTH = 60;           // mm
PANEL_THICKNESS = 3;        // mm
BUTTON_DIA = 12;            // mm
LED_DIA = 5;                // mm
DISPLAY_LENGTH = 40;        // mm
DISPLAY_HEIGHT = 20;        // mm
DISPLAY_CORNER_RADIUS = 2;  // mm
PANEL_MOUNT_HOLE_DIA = 3;   // mm (M3)
PANEL_TEXT_HEIGHT = 3;      // mm

// Assembly Parameters
CORE_Z_OFFSET = HOUSING_WALL;  // Core sits on housing base
PANEL_Z_OFFSET = HOUSING_HEIGHT - PANEL_THICKNESS;  // Panel on top front

// ============================================================================
// MODULE: Core Assembly
// ============================================================================
// Central processing and power unit with mounting holes
module core_assembly() {
    difference() {
        // Outer box
        cube([CORE_LENGTH, CORE_WIDTH, CORE_HEIGHT], center=true);
        
        // Inner cavity for components
        translate([0, 0, CORE_WALL/2]) {
            cube([
                CORE_LENGTH - 2*CORE_WALL,
                CORE_WIDTH - 2*CORE_WALL,
                CORE_HEIGHT - CORE_WALL
            ], center=true);
        }
        
        // M4 Mounting holes (4 holes at corners)
        mount_spacing_x = CORE_MOUNT_X;
        mount_spacing_y = CORE_MOUNT_Y;
        
        for (dx = [-1, 1]) {
            for (dy = [-1, 1]) {
                translate([
                    dx * mount_spacing_x / 2,
                    dy * mount_spacing_y / 2,
                    0
                ]) {
                    cylinder(
                        h = CORE_HEIGHT + 2,
                        r = CORE_MOUNT_HOLE_DIA / 2,
                        center = true
                    );
                }
            }
        }
    }
}

// ============================================================================
// MODULE: Core Assembly with Connector Interface
// ============================================================================
// Adds connector posts for internal components
module core_assembly_with_connectors() {
    core_assembly();
    
    // Internal connector posts (small standoffs)
    connector_height = 10;
    connector_dia = 3;
    
    for (x_pos = [-50, 0, 50]) {
        for (y_pos = [-25, 25]) {
            translate([x_pos, y_pos, -CORE_HEIGHT/2 + connector_height/2]) {
                cylinder(h = connector_height, r = connector_dia/2, center = true);
            }
        }
    }
}

// ============================================================================
// MODULE: Housing/Shell
// ============================================================================
// Protective enclosure with ventilation holes and cable management
module housing_shell() {
    difference() {
        // Outer shell
        cube([HOUSING_LENGTH, HOUSING_WIDTH, HOUSING_HEIGHT], center=true);
        
        // Inner cavity
        translate([0, 0, HOUSING_WALL/2]) {
            cube([
                HOUSING_LENGTH - 2*HOUSING_WALL,
                HOUSING_WIDTH - 2*HOUSING_WALL,
                HOUSING_HEIGHT - HOUSING_WALL
            ], center=true);
        }
        
        // Ventilation holes (grid pattern on sides)
        hole_count_x = 4;
        hole_count_y = 3;
        spacing_x = (HOUSING_LENGTH - 40) / (hole_count_x - 1);
        spacing_y = (HOUSING_HEIGHT - 40) / (hole_count_y - 1);
        
        // Ventilation on right side
        for (i = [0 : hole_count_x - 1]) {
            for (j = [0 : hole_count_y - 1]) {
                translate([
                    -HOUSING_LENGTH/2 + 20 + i * spacing_x,
                    HOUSING_WIDTH/2 + 1,
                    -HOUSING_HEIGHT/2 + 20 + j * spacing_y
                ]) {
                    cylinder(h = HOUSING_WALL + 2, r = VENT_HOLE_DIA/2, center=true);
                }
            }
        }
        
        // Ventilation on left side
        for (i = [0 : hole_count_x - 1]) {
            for (j = [0 : hole_count_y - 1]) {
                translate([
                    -HOUSING_LENGTH/2 + 20 + i * spacing_x,
                    -HOUSING_WIDTH/2 - 1,
                    -HOUSING_HEIGHT/2 + 20 + j * spacing_y
                ]) {
                    cylinder(h = HOUSING_WALL + 2, r = VENT_HOLE_DIA/2, center=true);
                }
            }
        }
        
        // M5 base mounting holes (4 holes at corners)
        corner_offset_x = HOUSING_LENGTH/2 - 10;
        corner_offset_y = HOUSING_WIDTH/2 - 10;
        
        for (dx = [-1, 1]) {
            for (dy = [-1, 1]) {
                translate([
                    dx * corner_offset_x,
                    dy * corner_offset_y,
                    -HOUSING_HEIGHT/2
                ]) {
                    cylinder(
                        h = HOUSING_WALL + 2,
                        r = HOUSING_MOUNT_HOLE_DIA / 2,
                        center = true
                    );
                }
            }
        }
        
        // Front opening for control panel
        translate([0, HOUSING_WIDTH/2, PANEL_Z_OFFSET - HOUSING_HEIGHT/2]) {
            cube([PANEL_LENGTH + 4, HOUSING_WALL + 2, PANEL_WIDTH + 4], center=true);
        }
    }
}

// ============================================================================
// MODULE: Control Interface Panel
// ============================================================================
// User interaction and status display with buttons, LEDs, and display window
module control_panel() {
    difference() {
        // Panel base
        cube([PANEL_LENGTH, PANEL_WIDTH, PANEL_THICKNESS], center=true);
        
        // Left button group (2 buttons)
        button_y_spacing = 15;
        for (i = [-1, 1]) {
            translate([-20, i * button_y_spacing, 0]) {
                cylinder(h = PANEL_THICKNESS + 2, r = BUTTON_DIA/2, center=true);
            }
        }
        
        // Right button group (2 buttons)
        for (i = [-1, 1]) {
            translate([20, i * button_y_spacing, 0]) {
                cylinder(h = PANEL_THICKNESS + 2, r = BUTTON_DIA/2, center=true);
            }
        }
        
        // Central display window (rectangular with rounded corners)
        translate([0, 0, 0]) {
            minkowski() {
                cube([
                    DISPLAY_LENGTH - 2*DISPLAY_CORNER_RADIUS,
                    DISPLAY_HEIGHT - 2*DISPLAY_CORNER_RADIUS,
                    PANEL_THICKNESS + 2
                ], center=true);
                cylinder(r = DISPLAY_CORNER_RADIUS, h = 0.01, center=true);
            }
        }
        
        // LED indicator holes
        led_positions = [
            [-35, 15],
            [-35, -15],
            [35, 15],
            [35, -15]
        ];
        
        for (pos = led_positions) {
            translate([pos[0], pos[1], 0]) {
                cylinder(h = PANEL_THICKNESS + 2, r = LED_DIA/2, center=true);
            }
        }
        
        // Panel mounting holes (M3)
        mount_corners_x = [-40, 40];
        mount_corners_y = [-25, 25];
        
        for (mx = mount_corners_x) {
            for (my = mount_corners_y) {
                translate([mx, my, 0]) {
                    cylinder(
                        h = PANEL_THICKNESS + 2,
                        r = PANEL_MOUNT_HOLE_DIA / 2,
                        center = true
                    );
                }
            }
        }
    }
    
    // Text labels
    translate([-20, -30, PANEL_THICKNESS/2 + 0.5]) {
        linear_extrude(height = 1) {
            text("POWER", size = 4, halign="center", font="Arial:style=Bold");
        }
    }
    
    translate([20, -30, PANEL_THICKNESS/2 + 0.5]) {
        linear_extrude(height = 1) {
            text("RESET", size = 4, halign="center", font="Arial:style=Bold");
        }
    }
}

// ============================================================================
// MODULE: Panel Frame/Bezel
// ============================================================================
// Frame that holds the control panel in place
module panel_frame() {
    frame_thickness = 5;
    
    difference() {
        // Outer frame
        cube([
            PANEL_LENGTH + 2*frame_thickness,
            PANEL_WIDTH + 2*frame_thickness,
            frame_thickness
        ], center=true);
        
        // Inner cutout for panel
        translate([0, 0, 1]) {
            cube([PANEL_LENGTH, PANEL_WIDTH, frame_thickness + 2], center=true);
        }
    }
    
    // Corner supports for mounting
    support_size = 8;
    support_height = 5;
    
    for (dx = [-1, 1]) {
        for (dy = [-1, 1]) {
            translate([
                dx * (PANEL_LENGTH/2 + frame_thickness),
                dy * (PANEL_WIDTH/2 + frame_thickness),
                -support_height/2
            ]) {
                cube([support_size, support_size, support_height], center=true);
            }
        }
    }
}

// ============================================================================
// MODULE: Cable Management Channel
// ============================================================================
// Internal routing for cables between components
module cable_channel() {
    channel_width = 8;
    channel_height = 6;
    channel_length = HOUSING_LENGTH - 20;
    
    translate([0, 0, -HOUSING_HEIGHT/2 + channel_height/2 + 5]) {
        cube([channel_length, channel_width, channel_height], center=true);
    }
}

// ============================================================================
// MODULE: Complete Assembly
// ============================================================================
// Shows all three parts in their assembled positions
module godiva_complete_assembly() {
    // Housing base
    translate([0, 0, 0]) {
        color("lightgray", 0.9) {
            housing_shell();
        }
    }
    
    // Core assembly mounted inside housing
    translate([0, 0, CORE_Z_OFFSET + CORE_HEIGHT/2]) {
        color("silver", 0.9) {
            core_assembly_with_connectors();
        }
    }
    
    // Cable management channel (for reference, not solid)
    %cable_channel();
    
    // Control panel mounted on front top
    translate([0, HOUSING_WIDTH/2 - PANEL_THICKNESS/2, HOUSING_HEIGHT/2 - PANEL_THICKNESS/2]) {
        color("darkblue", 0.95) {
            control_panel();
        }
    }
    
    // Panel frame/bezel
    translate([0, HOUSING_WIDTH/2 + 2, HOUSING_HEIGHT/2 - 2]) {
        color("black", 0.7) {
            panel_frame();
        }
    }
}

// ============================================================================
// MODULE: Exploded View
// ============================================================================
// Shows all components separated for visualization
module godiva_exploded_view() {
    explode_distance = 80;
    
    // Housing base
    translate([0, -explode_distance, 0]) {
        color("lightgray", 0.9) {
            housing_shell();
        }
    }
    
    // Core assembly
    translate([0, 0, CORE_Z_OFFSET + CORE_HEIGHT/2 + explode_distance]) {
        color("silver", 0.9) {
            core_assembly_with_connectors();
        }
    }
    
    // Control panel
    translate([explode_distance, 0, 0]) {
        color("darkblue", 0.95) {
            control_panel();
        }
    }
    
    // Panel frame
    translate([explode_distance, 0, -explode_distance/2]) {
        color("black", 0.7) {
            panel_frame();
        }
    }
}

// ============================================================================
// RENDER SELECTION
// ============================================================================
// Uncomment the desired view:

// Display complete assembly
godiva_complete_assembly();

// Uncomment below for exploded view:
// godiva_exploded_view();

// Uncomment individual components for detailed viewing:
// core_assembly_with_connectors();
// housing_shell();
// control_panel();
// panel_frame();

// ============================================================================
// END OF GODIVA DEVICE OPENSCAD SCRIPT
// ============================================================================
```

This complete OpenSCAD script implements the Godiva device with:

- **Parametric design**: All dimensions defined as variables at the top for easy modification
- **Core Assembly module**: 150x100x50mm with M4 mounting holes and internal connector posts
- **Housing/Shell module**: 165x115x70mm with ventilation grid pattern, M5 base mounting holes, and front panel opening
- **Control Panel module**: 100x60x3mm with 4 buttons, 4 LED indicators, central display window, M3 mounting holes, and text labels
- **Panel Frame module**: Bezel with corner supports for secure mounting
- **Cable Management**: Internal channel for cable routing
- **Complete Assembly**: Shows all parts correctly positioned and colored
- **Exploded View**: Alternative visualization mode for component understanding
- **Comprehensive comments**: Each section thoroughly documented

The script uses proper OpenSCAD syntax with modules for reusability and color coding for different materials.

