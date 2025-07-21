// OpenAPI 3.0.0 specification for the Betwizz API

interface BetwizzAPISpecification {
  openapi: "3.0.0";
  info: {
    title: "Betwizz API";
    version: "1.0.0";
    description: "API for the Betwizz sports betting intelligence platform.";
  };
  servers: [
    {
      url: "https://api.betwizz.co.za/v1";
      description: "Production server";
    },
    {
      url: "http://localhost:3000/v1";
      description: "Development server";
    }
  ];
  components: {
    securitySchemes: {
      BearerAuth: {
        type: "http";
        scheme: "bearer";
        bearerFormat: "JWT";
      };
    };
    schemas: {
      User: {
        type: "object";
        properties: {
          id: { type: "string"; format: "uuid" };
          email: { type: "string"; format: "email" };
          fica_verified: { type: "boolean" };
          createdAt: { type: "string"; format: "date-time" };
          updatedAt: { type: "string"; format: "date-time" };
        };
      };
      Channel: {
        type: "object";
        properties: {
          id: { type: "string"; format: "uuid" };
          creator_id: { type: "string"; format: "uuid" };
          name: { type: "string" };
          description: { type: "string" };
          subscription_tier: { type: "string"; enum: ["free", "basic", "premium", "elite"] };
          price: { type: "number"; format: "float" };
          is_live: { type: "boolean" };
          viewer_count: { type: "integer" };
        };
      };
      Subscription: {
        type: "object";
        properties: {
          id: { type: "string"; format: "uuid" };
          user_id: { type: "string"; format: "uuid" };
          channel_id: { type: "string"; format: "uuid" };
          tier: { type: "string"; enum: ["basic", "premium", "elite"] };
          status: { type: "string"; enum: ["active", "cancelled", "expired"] };
          payfast_subscription_id: { type: "string" };
          expires_at: { type: "string"; format: "date-time" };
        };
      };
      BetReceipt: {
        type: "object";
        properties: {
          id: { type: "string"; format: "uuid" };
          user_id: { type: "string"; format: "uuid" };
          bookmaker: { type: "string" };
          bet_type: { type: "string" };
          stake_amount: { type: "number"; format: "float" };
          odds: { type: "number"; format: "float" };
          is_win: { type: "boolean" };
          win_amount: { type: "number"; format: "float" };
          receipt_image_url: { type: "string" };
          ocr_data: { type: "object" };
        };
      };
    };
  };
  paths: {
    "/auth/register": {
      post: {
        summary: "Register a new user";
        requestBody: {
          required: true;
          content: {
            "application/json": {
              schema: {
                type: "object";
                properties: {
                  email: { type: "string"; format: "email" };
                  password: { type: "string" };
                };
              };
            };
          };
        };
        responses: {
          "201": { description: "User created successfully" };
          "400": { description: "Invalid input" };
        };
      };
    };
    "/auth/login": {
      post: {
        summary: "Login a user";
        requestBody: {
          required: true;
          content: {
            "application/json": {
              schema: {
                type: "object";
                properties: {
                  email: { type: "string"; format: "email" };
                  password: { type: "string" };
                };
              };
            };
          };
        };
        responses: {
          "200": {
            description: "Successful login";
            content: {
              "application/json": {
                schema: {
                  type: "object";
                  properties: {
                    token: { type: "string" };
                  };
                };
              };
            };
          };
          "401": { description: "Unauthorized" };
        };
      };
    };
    "/channels": {
      get: {
        summary: "Get all channels";
        responses: {
          "200": {
            description: "A list of channels";
            content: {
              "application/json": {
                schema: {
                  type: "array";
                  items: { $ref: "#/components/schemas/Channel" };
                };
              };
            };
          };
        };
      };
    };
  };
}
