// Raylib
const rl = @import("raylib");

// Screen dimensions
const SCR_WIDTH: u16 = 800;
const SCR_HEIGHT: u16 = 600;

// Player scores
var player1Score: u8 = 0;
var player2Score: u8 = 0;

// Ball
const Ball = struct {
    // Properties
    position: rl.Vector2,
    speed: rl.Vector2,
    radius: f32,
    color: rl.Color,

    // Methods
    // Create a ball
    pub fn init(position: rl.Vector2, radius: f32, speed: f32, color: rl.Color) Ball {
        return Ball {
            .position = position,
            .radius = radius,
            .speed = rl.Vector2.init(speed, speed),
            .color = color,
        };
    }

    // Update - Collisions and stuff
    pub fn update(self: *Ball) void {
        // Movement
        self.position = rl.Vector2.add(
            self.position,
            rl.Vector2.init(self.speed.x * rl.getFrameTime(), self.speed.y * rl.getFrameTime())
        );

        // Collision
        if(self.position.y - self.radius <= 0 or self.position.y + self.radius >= SCR_HEIGHT) self.speed.y *= -1;
        if(self.position.x - self.radius <= 0) {
            player2Score += 1;
            self.position.x = SCR_WIDTH / 2;
            self.position.y = SCR_HEIGHT / 2;
            self.speed.x *= -1;
        }
        if(self.position.x + self.radius >= SCR_WIDTH) {
            player1Score += 1;
            self.position.x = SCR_WIDTH / 2;
            self.position.y = SCR_HEIGHT / 2;
            self.speed.x *= -1;
        }
    }

    // Render the ball
    pub fn render(self: *Ball) void {rl.drawCircleV(self.position, self.radius, self.color);}
};

// Paddle
const Paddle = struct {
    // Properties
    mode: u8,
    position: rl.Vector2,
    size: rl.Vector2,
    speed: f32,
    color: rl.Color,

    // Methods
    // Create a paddle
    pub fn init(mode: u8, pos: rl.Vector2, size: rl.Vector2, speed: f32, color: rl.Color) Paddle {
        return Paddle {
            .mode = mode,
            .position = pos,
            .size = size,
            .speed = speed,
            .color = color,
        };
    }

    // Update - Collisions and stuff
    pub fn update(self: *Paddle, ball: *Ball) void {
        // Movement
        if(self.mode == 1) {
            if(rl.isKeyDown(rl.KeyboardKey.key_up)) {self.position.y -= self.speed * rl.getFrameTime();}
            else if(rl.isKeyDown(rl.KeyboardKey.key_down)) {self.position.y += self.speed * rl.getFrameTime();}
        } else {
            if(rl.isKeyDown(rl.KeyboardKey.key_w)) {self.position.y -= self.speed * rl.getFrameTime();}
            else if(rl.isKeyDown(rl.KeyboardKey.key_s)) {self.position.y += self.speed * rl.getFrameTime();}
        }

        // Stop the paddle from going out of the screen
        if(self.position.y <= 0) {self.position.y = 0;}
        else if(self.position.y + self.size.y >= SCR_HEIGHT) {self.position.y = SCR_HEIGHT - self.size.y;}

        // Check if the ball is colliding with the paddle
        if(rl.checkCollisionCircleRec(
            ball.position, ball.radius,
            rl.Rectangle {
                .x = self.position.x, .y = self.position.y, .width = self.size.x, .height = self.size.y
            }
        )) {ball.speed.x *= -1;}
    }

    // Render the paddle
    pub fn render(self: *Paddle) void {
        rl.drawRectangleV(self.position, self.size, self.color);
    }
};

// Main
pub fn main() anyerror!void {
    // Initialize Raylib
    rl.initWindow(SCR_WIDTH, SCR_HEIGHT, "Pong");
    defer rl.closeWindow();

    // Set application settings
    rl.setTargetFPS(120);

    // Ball
    var ball: Ball = Ball.init(
        rl.Vector2.init(SCR_WIDTH / 2, SCR_HEIGHT / 2),
        12,
        250,
        rl.Color.white
    );

    // Paddles
    var paddle1: Paddle = Paddle.init(
        1,
        rl.Vector2.init(10, SCR_HEIGHT / 2 - 50),
        rl.Vector2.init(15, 100),
        300,
        rl.Color.white,
    );
    var paddle2: Paddle = Paddle.init(
        2,
        rl.Vector2.init(SCR_WIDTH - 25, SCR_HEIGHT / 2 - 50),
        rl.Vector2.init(15, 100),
        300,
        rl.Color.white,
    );

    // Main loop
    while(!rl.windowShouldClose()) {
        // Update everything
        {
            ball.update();
            paddle1.update(&ball);
            paddle2.update(&ball);
        }
        
        // Render everything
        {
            // Draw cycle
            rl.beginDrawing();
            defer rl.endDrawing();

            // Clear the screen
            rl.clearBackground(rl.Color.black);

            // Draw the line between the 2 paddles
            rl.drawLine(SCR_WIDTH / 2, 0, SCR_WIDTH / 2, SCR_HEIGHT, rl.Color.white);

            // Render the ball and the paddles
            ball.render();
            paddle1.render();
            paddle2.render();

            // Interface/UI
            rl.drawText(rl.textFormat("%i", .{player1Score}), 10, 10, 20, rl.Color.white);
            rl.drawText(rl.textFormat("%i", .{player2Score}), SCR_WIDTH - 30, 10, 20, rl.Color.white);
            rl.drawFPS(10, SCR_HEIGHT - 30);
        }
    }
}
