# TripSense

AI-powered travel recommendation system designed to help users discover and plan personalized trips based on their preferences, budget, and location constraints.

## 🚀 Project Overview

TripSense is a full-stack travel planning application that combines:
- **Flutter Mobile Frontend** - Cross-platform mobile app (iOS, Android, Web, Desktop)
- **Spring Boot Backend** - RESTful API with JWT authentication and MySQL database
- **Node.js AI Service** - Express-based microservice with OpenAI integration for intelligent recommendations

The system allows users to specify travel preferences (categories, locations, dates, budget, distance) and receive AI-generated or locally-generated travel recommendations tailored to their needs.

## 📋 Architecture

```
tripsense/
├── tripsense-frontend/        # Flutter mobile application
├── tripsense-service/         # Spring Boot backend API
└── tripsense-ai-service/      # Node.js AI recommendation service
```

### Components

#### 1. Frontend (Flutter)
- **Technology**: Flutter SDK 3.8.1+
- **Features**:
  - User authentication (Login/Register)
  - Multi-step preference selection
  - Categories: Adventure, Beach, Cultural, Leisure, Nature, Romantic, Wildlife, Historical
  - Location selection with coordinates
  - Date range picker
  - Budget and distance constraints
  - Dashboard with recommendations visualization
  - User profile management

#### 2. Backend Service (Spring Boot)
- **Technology**: Java 21, Spring Boot 3.5.0, MySQL 8.0
- **Features**:
  - User registration and authentication (JWT)
  - Spring Security integration
  - User preference management
  - Role-based access control (USER, ADMIN)
  - RESTful API endpoints
  - Swagger/OpenAPI documentation
  - MySQL database persistence

#### 3. AI Service (Node.js)
- **Technology**: Node.js, Express 4.18, OpenAI 4.53
- **Features**:
  - Travel recommendation generation
  - OpenAI GPT integration (optional)
  - Local fallback recommendation engine
  - Distance calculation (Haversine formula)
  - User proxy API
  - CORS-enabled for cross-origin requests

## 🛠️ Prerequisites

### General Requirements
- Git
- Internet connection for package downloads

### Frontend Requirements
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (^3.8.1)
- Dart SDK (included with Flutter)
- Platform-specific requirements:
  - **iOS**: Xcode, CocoaPods
  - **Android**: Android Studio, Android SDK
  - **Windows**: Visual Studio 2019+ with C++ desktop development
  - **macOS**: Xcode
  - **Linux**: clang, cmake, ninja-build, libgtk-3-dev

### Backend Requirements
- [Java JDK 21](https://www.oracle.com/java/technologies/downloads/#java21)
- [Maven 3.6+](https://maven.apache.org/download.cgi)
- [MySQL 8.0+](https://dev.mysql.com/downloads/mysql/)

### AI Service Requirements
- [Node.js 16+](https://nodejs.org/) and npm
- OpenAI API key (optional, for AI-powered recommendations)

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/SasmithaHiram/tripsense.git
cd tripsense
```

### 2. Database Setup

Create a MySQL database for the application:

```sql
CREATE DATABASE tripsense;
CREATE USER 'tripsense_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON tripsense.* TO 'tripsense_user'@'localhost';
FLUSH PRIVILEGES;
```

### 3. Backend Service Setup

```bash
cd tripsense-service
```

Configure database connection in `src/main/resources/application.properties`:

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/tripsense
spring.datasource.username=tripsense_user
spring.datasource.password=your_password
spring.jpa.hibernate.ddl-auto=update
```

Build and run:

```bash
mvn clean install
mvn spring-boot:run
```

The backend will start at `http://localhost:8080`

**API Documentation**: Access Swagger UI at `http://localhost:8080/swagger-ui.html`

### 4. AI Service Setup

```bash
cd tripsense-ai-service
npm install
```

Create a `.env` file (optional):

```env
OPENAI_API_KEY=sk-your-api-key-here
OPENAI_MODEL=gpt-4o-mini
PORT=3000
USER_SERVICE_BASE=http://localhost:8080
```

**Note**: The service works without OpenAI API key using a local recommendation engine.

Run the service:

```bash
npm start
```

The AI service will start at `http://localhost:3000`

### 5. Frontend Setup

```bash
cd tripsense-frontend
flutter pub get
```

**Windows Developer Mode** (for plugin support):
```powershell
start ms-settings:developers
```

Run the application:

```bash
# For web
flutter run -d chrome

# For mobile (with connected device/emulator)
flutter run

# For desktop
flutter run -d windows  # or macos, linux
```

## 🔧 Configuration

### Backend Endpoints

The Spring Boot service exposes these main endpoints:

- **Auth**: `POST /api/v1/auth/login`, `/api/v1/auth/register`
- **Users**: `GET /api/v1/users/{email}`, `POST /api/v1/users/register`
- **Preferences**: `POST /api/v1/preferences`, `GET /api/v1/preferences`
- **Admin**: Various admin endpoints (requires ADMIN role)

### AI Service Endpoints

- **Health Check**: `GET /` - Returns service status
- **Recommendations**: `POST /api/recomendations` - Generate trip recommendations
- **Distance**: `POST /api/distance-km` - Calculate distance between coordinates
- **User Proxy**: `GET /api/users/:email` - Proxy to backend user service

### Frontend Configuration

Update API base URLs in:
- `lib/services/auth_service.dart` - Backend authentication
- `lib/services/api_service.dart` - Backend API calls
- Preference submission - Points to backend `/api/v1/preferences`

Default configuration assumes:
- Backend: `http://localhost:8080`
- AI Service: `http://localhost:3000`

## 📝 API Examples

### Create User Preferences

```bash
curl -X POST http://localhost:8080/api/v1/preferences \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "categories": ["Adventure", "Nature"],
    "locations": ["Colombo", "Kandy"],
    "startDate": "2026-01-10",
    "endDate": "2026-01-15",
    "maxDistanceKm": 120,
    "maxBudget": 50000.0
  }'
```

### Get AI Recommendations

```bash
curl -X POST http://localhost:3000/api/recomendations \
  -H "Content-Type: application/json" \
  -d '{
    "preferences": [{
      "categories": ["beach", "food"],
      "locations": ["Galle", "Mirissa"],
      "startDate": "2026-01-10",
      "endDate": "2026-01-12",
      "maxDistanceKm": 150,
      "maxBudget": 100
    }]
  }'
```

### Calculate Distance

```bash
curl -X POST http://localhost:3000/api/distance-km \
  -H "Content-Type: application/json" \
  -d '{
    "from": {"lat": 6.9271, "lng": 79.8612},
    "to": {"lat": 6.0535, "lng": 80.221}
  }'
```

## 🧪 Testing

### Backend Tests

```bash
cd tripsense-service
mvn test
```

### Frontend Tests

```bash
cd tripsense-frontend
flutter test
```

## 🏗️ Build for Production

### Backend

```bash
cd tripsense-service
mvn clean package
java -jar target/tripsense-service-1.0-SNAPSHOT.jar
```

### Frontend

```bash
cd tripsense-frontend

# Android APK
flutter build apk --release

# iOS IPA (macOS only)
flutter build ios --release

# Web
flutter build web --release

# Windows executable
flutter build windows --release
```

### AI Service

```bash
cd tripsense-ai-service
# Use a process manager like PM2
npm install -g pm2
pm2 start app.js --name tripsense-ai
```

## 🔐 Security

- **JWT Authentication**: The backend uses JWT tokens for secure API access
- **Password Hashing**: User passwords are securely hashed (Spring Security)
- **CORS**: Configured in AI service for cross-origin requests
- **Environment Variables**: Sensitive data (API keys, DB credentials) should be in environment variables
- **Role-Based Access**: ADMIN and USER roles for different access levels

## 🌍 Environment Variables

### Backend (application.properties)

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/tripsense
spring.datasource.username=your_username
spring.datasource.password=your_password
jwt.secret=your_jwt_secret_key_here
jwt.expiration=86400000
```

### AI Service (.env)

```env
PORT=3000
OPENAI_API_KEY=sk-your-openai-key
OPENAI_MODEL=gpt-4o-mini
USER_SERVICE_BASE=http://localhost:8080
```

## 🐛 Troubleshooting

### Frontend Issues

**Windows Plugin Error**: Enable Developer Mode in Windows Settings → Update & Security → For developers

**Build Errors**: Run `flutter clean && flutter pub get`

### Backend Issues

**Database Connection**: Verify MySQL is running and credentials are correct

**Port Already in Use**: Change port in `application.properties`: `server.port=8081`

### AI Service Issues

**OpenAI Errors**: Service falls back to local recommendations if API key is invalid/missing

**CORS Errors**: Ensure CORS is enabled in `app.js` (already configured)

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Express.js Documentation](https://expressjs.com/)
- [OpenAI API Documentation](https://platform.openai.com/docs)

## 📄 License

UNLICENSED - This is a private project

## 👥 Contributors

- Sasmitha Hiram

## 🤝 Contributing

This is a private project. For contributions, please contact the repository owner.

## 📞 Support

For issues or questions, please open an issue on GitHub or contact the maintainer.

---

**Happy Traveling! 🌴✈️🗺️**
