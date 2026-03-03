# Dart Frog Backend Demo

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]
[![Powered by Dart Frog](https://img.shields.io/endpoint?url=https://tinyurl.com/dartfrog-badge)](https://dartfrog.vgv.dev)

Backend API application built with Dart Frog, featuring RESTful endpoints, GraphQL support, WebSocket, and real-time communication. Demonstrates CRUD operations, GraphQL queries, middleware implementation, and state management with broadcast_bloc.

## Prerequisites

Before getting started, make sure you have the following installed:

- **Dart SDK**: >=3.11.0 <4.0.0
- **Dart Frog CLI**: Latest version
- **IDE**: VSCode or IntelliJ IDEA with Dart extensions

## Initial Setup

### 1. Install Dart Frog CLI

If you haven't installed Dart Frog CLI yet, install it globally:

```bash
dart pub global activate dart_frog_cli
```

Verify installation:

```bash
dart_frog --version
```

### 2. Clone the repository

```bash
git clone <repository-url>
cd dart_frog_backend_demo
```

### 3. Install dependencies

```bash
dart pub get
```

### 4. Generate code

This project uses code generation for JSON serialization:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Development

### Run the development server

Start the Dart Frog development server with hot reload:

```bash
dart_frog dev
```

The server will start at `http://localhost:8080` by default.

### Custom port

To run on a different port:

```bash
dart_frog dev --port 3000
```

### Watch for changes

The dev server automatically reloads on file changes. No need to restart!

## Production

### Build for production

Build an optimized production server:

```bash
dart_frog build
```

This creates a compiled executable in `build/`.

### Run production build

```bash
dart build/bin/server.dart
```

### Production with custom configuration

```bash
# Custom port
dart build/bin/server.dart --port 8080

# Custom host
dart build/bin/server.dart --host 0.0.0.0
```

## Project Structure

```
dart_frog_backend_demo/
├── routes/                             # API route handlers
│   ├── _middleware.dart                # Global middleware
│   ├── index.dart                      # GET / - Root endpoint
│   ├── ws.dart                         # WebSocket endpoint
│   ├── graphql.dart                    # POST /graphql - GraphQL endpoint
│   └── json/                           # JSON CRUD endpoints
│       ├── index.dart                  # GET/POST /json
│       └── [id].dart                   # GET/PUT/DELETE /json/:id
├── lib/                                # Shared business logic
│   ├── graphql/                        # GraphQL configuration
│   │   └── graph_ql_schemas.dart       # GraphQL schema setup
│   └── model/                          # Data models
│       ├── user/                       # User model
│       │   ├── user_model.dart         # User data class
│       │   └── graphql/                # User GraphQL schema
│       │       └── user_schema.dart    # User type definition
│       └── address/                    # Address model
│           └── address_model.dart      # Address data class
├── test/                               # Unit and integration tests
│   ├── routes/                         # Route handler tests
│   └── models/                         # Model tests
├── public/                             # Static files
├── .dart_frog/                         # Generated Dart Frog files (don't edit)
├── main.dart                           # Server entry point
├── pubspec.yaml                        # Dependencies
└── analysis_options.yaml               # Linter rules
```

## API Endpoints

### Root Endpoint

#### GET /

Welcome endpoint returning server information.

```bash
curl http://localhost:8080/
```

**Response:**
```json
{
  "message": "Welcome to Dart Frog!",
  "version": "1.0.0"
}
```

### JSON CRUD Endpoints

#### GET /json

Get all JSON items.

```bash
curl http://localhost:8080/json
```

**Response:**
```json
{
  "items": [
    {
      "id": "uuid-1",
      "name": "Item 1",
      "createdAt": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

#### POST /json

Create a new JSON item.

```bash
curl -X POST http://localhost:8080/json \
  -H "Content-Type: application/json" \
  -d '{"name": "New Item"}'
```

**Request Body:**
```json
{
  "name": "New Item"
}
```

**Response:**
```json
{
  "id": "uuid-2",
  "name": "New Item",
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

#### GET /json/:id

Get a specific JSON item by ID.

```bash
curl http://localhost:8080/json/uuid-1
```

**Response:**
```json
{
  "id": "uuid-1",
  "name": "Item 1",
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

#### PUT /json/:id

Update an existing JSON item.

```bash
curl -X PUT http://localhost:8080/json/uuid-1 \
  -H "Content-Type: application/json" \
  -d '{"name": "Updated Item"}'
```

**Request Body:**
```json
{
  "name": "Updated Item"
}
```

**Response:**
```json
{
  "id": "uuid-1",
  "name": "Updated Item",
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T01:00:00.000Z"
}
```

#### DELETE /json/:id

Delete a JSON item.

```bash
curl -X DELETE http://localhost:8080/json/uuid-1
```

**Response:**
```json
{
  "message": "Item deleted successfully",
  "id": "uuid-1"
}
```

### WebSocket Endpoint

#### WS /ws

WebSocket endpoint for real-time bidirectional communication.

**JavaScript Client Example:**
```javascript
const ws = new WebSocket('ws://localhost:8080/ws');

ws.onopen = () => {
  console.log('Connected');
  ws.send(JSON.stringify({ type: 'ping' }));
};

ws.onmessage = (event) => {
  console.log('Received:', event.data);
};

ws.onerror = (error) => {
  console.error('WebSocket error:', error);
};

ws.onclose = () => {
  console.log('Disconnected');
};
```

**Dart Client Example:**
```dart
import 'package:web_socket_channel/web_socket_channel.dart';

final channel = WebSocketChannel.connect(
  Uri.parse('ws://localhost:8080/ws'),
);

channel.stream.listen((message) {
  print('Received: $message');
});

channel.sink.add('{"type": "ping"}');
```

### GraphQL Endpoint

#### POST /graphql

GraphQL endpoint for querying data with flexible queries.

**Query - Get all users:**

```bash
curl -X POST http://localhost:8080/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ users { name age serverMessage address { street number zipCode } } }"}'
```

**Response:**
```json
{
  "data": {
    "users": [
      {
        "name": "Dash",
        "age": 42,
        "serverMessage": "Hello from server",
        "address": {
          "street": "Main St",
          "number": 123,
          "zipCode": 12345
        }
      }
    ]
  }
}
```

**Query - Find user by ID:**

```bash
curl -X POST http://localhost:8080/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ findUser(id: 1) { name age address { street number } } }"}'
```

**Response:**
```json
{
  "data": {
    "findUser": {
      "name": "Dash",
      "age": 42,
      "address": {
        "street": "Main St",
        "number": 123
      }
    }
  }
}
```

**Available Queries:**

| Query      | Arguments | Returns  | Description       |
| ---------- | --------- | -------- | ----------------- |
| `users`    | -         | `[User]` | Get all users     |
| `findUser` | `id: Int` | `User`   | Find a user by ID |

**User Type:**

| Field           | Type      | Description         |
| --------------- | --------- | ------------------- |
| `name`          | `String`  | User's name         |
| `age`           | `Int`     | User's age          |
| `serverMessage` | `String`  | Message from server |
| `address`       | `Address` | User's address      |

**Address Type:**

| Field     | Type     | Description   |
| --------- | -------- | ------------- |
| `street`  | `String` | Street name   |
| `number`  | `Int`    | Street number |
| `zipCode` | `Int`    | ZIP code      |

## Features

### RESTful API

- **CRUD Operations**: Complete Create, Read, Update, Delete functionality
- **JSON Serialization**: Type-safe JSON handling with code generation
- **UUID Generation**: Unique identifiers for resources
- **HTTP Methods**: Support for GET, POST, PUT, DELETE
- **Request Validation**: Input validation and error handling
- **Response Formatting**: Consistent JSON response structure

### GraphQL Support

- **Flexible Queries**: Query exactly the data you need
- **Type System**: Strongly typed schema with User and Address types
- **Nested Objects**: Support for nested object queries (User -> Address)
- **Query Arguments**: Support for query parameters (e.g., `findUser(id: 1)`)
- **Schema Definition**: Clean schema definition using `graphql_schema2`

### WebSocket Support

- **Real-time Communication**: Bidirectional communication with clients
- **Broadcast Messages**: Send messages to all connected clients
- **Event Handling**: Custom event types and handlers
- **Connection Management**: Track connected clients
- **State Synchronization**: Real-time state updates across clients

### Middleware

- **Global Middleware**: Applied to all routes via `_middleware.dart`
- **Request Logging**: Log all incoming requests
- **CORS Headers**: Cross-Origin Resource Sharing support
- **Error Handling**: Centralized error handling
- **Request Timing**: Track request duration
- **Custom Headers**: Add custom response headers

### State Management

- **broadcast_bloc**: Reactive state management for WebSocket
- **In-Memory Storage**: Fast in-memory data storage (development)
- **State Broadcasting**: Broadcast state changes to WebSocket clients
- **Event Sourcing**: Track all state changes

### Developer Experience

- **Hot Reload**: Instant server reload on code changes
- **Type Safety**: Full Dart type safety
- **Code Generation**: Automated JSON serialization
- **Testing Support**: Built-in testing utilities
- **Linting**: Strict code quality with very_good_analysis

## Middleware

### Global Middleware (_middleware.dart)

The global middleware handles:

1. **CORS Headers**: Enable cross-origin requests
2. **Request Logging**: Log method, path, and timestamp
3. **Error Handling**: Catch and format errors
4. **Performance Monitoring**: Track request duration

Example middleware implementation:

```dart
Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(provider<String>((_) => 'dependency'))
      .use(cors());
}
```

### Custom Middleware

Create route-specific middleware by adding `_middleware.dart` in any route directory.

## Testing

### Run all tests

```bash
dart test
```

### Run tests with coverage

```bash
dart test --coverage=coverage
```

### Generate coverage report

```bash
# Install coverage tools
dart pub global activate coverage

# Generate LCOV report
dart pub global run coverage:format_coverage \
  --lcov \
  --in=coverage \
  --out=coverage/lcov.info \
  --report-on=lib

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html
```

### Run specific test file

```bash
dart test test/routes/json/index_test.dart
```

## Code Quality

### Run code analysis

The project uses `very_good_analysis` to maintain code quality:

```bash
dart analyze
```

### Format code

```bash
dart format .
```

### Fix formatting issues

```bash
dart fix --apply
```

## Main Dependencies

### Framework

- **dart_frog**: Fast, minimalistic backend framework for Dart
- **dart_frog_web_socket**: WebSocket support for Dart Frog

### State Management

- **broadcast_bloc**: BLoC pattern with broadcast capabilities

### GraphQL

- **graphql_schema2**: GraphQL schema definition
- **graphql_server2**: GraphQL server implementation

### Data Serialization

- **json_annotation**: JSON serialization annotations
- **json_serializable**: Code generation for JSON serialization

### Utilities

- **uuid**: Generate unique identifiers

### Dev Dependencies

- **build_runner**: Code generation runner
- **test**: Dart testing framework
- **mocktail**: Mocking library for tests
- **very_good_analysis**: Strict lint rules

## Architecture

### Route-Based Architecture

Dart Frog uses a file-system based routing:

- Files in `routes/` directory automatically become endpoints
- `index.dart` maps to directory path
- `[param].dart` creates dynamic route parameters
- `_middleware.dart` applies middleware to routes in the directory

### Request Lifecycle

1. **Request Received**: Incoming HTTP request
2. **Middleware Chain**: Global and route-specific middleware
3. **Route Handler**: Matched route handler executes
4. **Response**: JSON or custom response returned
5. **Logging**: Request logged and metrics collected

### Dependency Injection

Dart Frog supports dependency injection via `provider`:

```dart
// In middleware
handler.use(provider<DatabaseService>((_) => DatabaseService()));

// In route
final database = context.read<DatabaseService>();
```

## Deployment

### Docker Deployment

Create a `Dockerfile`:

```dockerfile
FROM dart:stable AS build

WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart pub get --offline
RUN dart run build_runner build --delete-conflicting-outputs
RUN dart_frog build

FROM dart:stable-slim
COPY --from=build /app/build/bin/server /app/bin/
COPY --from=build /app/public /app/public

EXPOSE 8080
CMD ["/app/bin/server"]
```

Build and run:

```bash
docker build -t dart-frog-app .
docker run -p 8080:8080 dart-frog-app
```

### Cloud Deployment

#### Google Cloud Run

```bash
# Build production server
dart_frog build

# Deploy to Cloud Run
gcloud run deploy dart-frog-app \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

#### AWS Lambda

Use `dart_frog_lambda` package for AWS Lambda deployment.

#### Heroku

Create `Procfile`:

```
web: dart build/bin/server.dart --port $PORT
```

Deploy:

```bash
heroku create
git push heroku main
```

## Environment Variables

### Configuration

Use environment variables for configuration:

```dart
import 'dart:io';

final port = int.parse(Platform.environment['PORT'] ?? '8080');
final host = Platform.environment['HOST'] ?? 'localhost';
final databaseUrl = Platform.environment['DATABASE_URL'];
```

### Local Development

Create `.env` file (don't commit):

```env
PORT=8080
HOST=localhost
DATABASE_URL=postgresql://localhost/db
API_KEY=your_secret_key
```

Load with a package like `dotenv`:

```dart
import 'package:dotenv/dotenv.dart';

final env = DotEnv()..load();
final apiKey = env['API_KEY'];
```

## Troubleshooting

### Error: "dart_frog command not found"

Install Dart Frog CLI globally:

```bash
dart pub global activate dart_frog_cli
```

Add to PATH (if needed):

```bash
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

### Port already in use

Change the port:

```bash
dart_frog dev --port 3000
```

Or kill the process using port 8080:

```bash
# macOS/Linux
lsof -ti:8080 | xargs kill -9

# Windows
netstat -ano | findstr :8080
taskkill /PID <PID> /F
```

### Hot reload not working

1. Save the file explicitly
2. Check for syntax errors
3. Restart dev server:
   ```bash
   dart_frog dev
   ```

### WebSocket connection fails

- Verify WebSocket endpoint is running
- Check CORS configuration
- Use correct protocol (ws:// not http://)
- Check firewall settings

### Code generation fails

Clean and regenerate:

```bash
dart run build_runner clean
dart pub get
dart run build_runner build --delete-conflicting-outputs
```

### Tests not running

Ensure test dependencies are installed:

```bash
dart pub get
```

Run with verbose output:

```bash
dart test --reporter=expanded
```

### CORS errors

Add CORS middleware in `_middleware.dart`:

```dart
Handler middleware(Handler handler) {
  return handler.use(cors());
}

Middleware cors() {
  return (handler) {
    return (context) async {
      final response = await handler(context);
      return response.copyWith(
        headers: {
          ...response.headers,
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
          'Access-Control-Allow-Headers': 'Content-Type',
        },
      );
    };
  };
}
```

### Production build fails

1. Run code generation first
2. Check for Dart analysis errors
3. Verify all dependencies are compatible

```bash
dart analyze
dart run build_runner build --delete-conflicting-outputs
dart_frog build
```

## License

This project is licensed under the MIT License - see the [LICENSE](https://opensource.org/licenses/MIT) for details.

---

Generated with [Dart Frog](https://dartfrog.vgv.dev) 🐸

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
