const std = @import("std");     // Standard library - For the builder
const rlz = @import("raylib-zig");    // Raylib Zig - Zig bindings for Raylib

// Settings
const PROJECT_NAME = "Zong";

// Builder
pub fn build(b: *std.Build) !void {
    // Allow the person running 'zig build' to choose target system and optimization mode
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Dependencies
    const raylibDep = b.dependency("raylib-zig", .{
        .target = target,
        .optimize = optimize,
        .linux_display_backend = rlz.LinuxDisplayBackend.Wayland,
    });

    // Modules
    const raylib = raylibDep.module("raylib");
    const raygui = raylibDep.module("raygui");

    // Artifacts
    const raylibArtifact = raylibDep.artifact("raylib");

    // Web exports
    if(target.query.os_tag == .emscripten) {
        // Compile program for Emscripten
        const exeLib = try rlz.emcc.compileForEmscripten(b, PROJECT_NAME, "src/main.zig", target, optimize);

        // Link libraries
        exeLib.linkLibrary(raylibArtifact);

        // Add modules that can be imported in our program
        exeLib.root_module.addImport("raylib", raylib);
        exeLib.root_module.addImport("raygui", raygui);

        // Raylib itself isn't actually added to the "exeLib" output file so it also needs to be linked with Emscripten
        const linkStep = try rlz.emcc.linkWithEmscripten(b, &[_]*std.Build.Step.Compile{ exeLib, raylibArtifact });

        // Allows your program to access files like "resources/my-image.png"
        linkStep.addArg("--embed-file");
        linkStep.addArg("resources/");

        b.getInstallStep().dependOn(&linkStep.step);

        // Run step
        const runStep = try rlz.emcc.emscriptenRunStep(b);
        runStep.step.dependOn(&linkStep.step);
        const runOption = b.step("run", "Run " ++ PROJECT_NAME);
        runOption.dependOn(&runStep.step);

        return;
    }

    // Native application/executable
    const exe = b.addExecutable(.{
        .name = PROJECT_NAME,
        .root_source_file = b.path("src/main.zig"),
        .optimize = optimize,
        .target = target
    });

    // Set include directory
    exe.addIncludePath(b.path("./include/"));

    // Link libraries
    exe.linkLibrary(raylibArtifact);

    // Add modules that can be imported in our program
    exe.root_module.addImport("raylib", raylib);
    exe.root_module.addImport("raygui", raygui);

    // Run step
    const runCmd = b.addRunArtifact(exe);
    const runStep = b.step("run", "Run learningRaylib");
    runStep.dependOn(&runCmd.step);

    // Install program
    b.installArtifact(exe);
}
