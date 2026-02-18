# 🐄 API Requirements & Backend Parameters

This document outlines the API endpoints and data structures required to support the Cattle Management System.

## 1. Authentication

### 1.1 Register User
*   **Endpoint:** `POST /api/auth/register`
*   **Request Body:**
    ```json
    {
      "name": "Mohit",
      "mobile": "8155899949",
      "gaushalaName": "Smart Gaushala",
      "city": "Surat",
      "totalCows": 12,
      "password": "encrypted_password"
    }
    ```
*   **Response:**
    *   Success: `{ "success": true, "token": "jwt_token", "user": { ... } }`
    *   Error: `{ "success": false, "message": "User already exists" }`

### 1.2 Login User
*   **Endpoint:** `POST /api/auth/login`
*   **Request Body:**
    ```json
    {
      "mobile": "8155899949",
      "password": "password"
    }
    ```
*   **Response:**
    *   Success: `{ "success": true, "token": "jwt_token", "user": { ... } }`

---

## 2. Home Dashboard (Gaushala)

### 2.1 Get Dashboard Summary
*   **Endpoint:** `GET /api/dashboard/summary`
*   **Response:**
    ```json
    {
      "allCows": 8,
      "allBulls": 10,
      "cattleStatus": {
        "lactating": 3,
        "heifer": 3,
        "calving": 3,
        "dry": 3
      },
      "production": {
        "todayTotal": 52.0,
        "morning": 26.0,
        "evening": 26.0
      },
      "healthStats": {
          "heatRecord": 5,
          "conception": 2,
          "dryOff": 1
      },
      "alerts": 2,
      "reports": 5
    }
    ```

### 2.2 Get Animal Health Information (NEW)
*   **Endpoint:** `GET /api/dashboard/health-info`
*   **Response:**
    ```json
    {
      "medicalCount": 5,
      "vaccinationCount": 12,
      "dewormingCount": 8,
      "labTestingCount": 3,
      "sickAnimals": {
          "count": 0,
          "details": [] 
      }
    }
    ```

---

## 3. Milk Distribution (NEW)

### 3.1 Get Distribution Titles
*   **Endpoint:** `GET /api/distribution/titles`
*   **Response:**
    ```json
    {
      "titles": [
        "Local Dairy",
        "Society Member",
        "Temple Donation"
      ]
    }
    ```
*   **Note:** Returns a list of strings added by the user.

### 3.2 Add Distribution Title
*   **Endpoint:** `POST /api/distribution/titles`
*   **Request Body:**
    ```json
    {
      "title": "New Distribution Title"
    }
    ```
*   **Response:** Success confirmation.

### 3.3 Get Daily Distribution Records
*   **Endpoint:** `GET /api/distribution/records`
*   **Query Parameters:** `date` (YYYY-MM-DD), `shift` (morning/evening)
*   **Response:**
    ```json
    {
      "date": "2025-12-31",
      "shift": "morning",
      "records": [
        {
          "id": "rec_001",
          "title": "Local Dairy",
          "liters": 15.0,
          "fat": 4.5,
          "rate": 35.0,
          "amount": 525.0
        }
      ],
      "totalLiters": 15.0
    }
    ```

### 3.4 Add Distribution Record
*   **Endpoint:** `POST /api/distribution/records`
*   **Request Body:**
    ```json
    {
      "date": "2025-12-31",
      "shift": "morning",
      "title": "Local Dairy",
      "liters": 10.0,
      "fat": 4.0,
      "rate": 40.0,
      "amount": 400.0
    }
    ```

---

## 4. GauGram (Social Feed)

### 4.1 Get Posts
*   **Endpoint:** `GET /api/gaugram/posts`
*   **Parameters:** `page` (int), `limit` (int)
*   **Response:**
    ```json
    {
      "posts": [
        {
          "id": "post_123",
          "author": {
            "id": "user_456",
            "name": "Ravi Akhiyaniya",
            "gaushalaName": "Hari Om Gir Gaushala",
            "avatarUrl": "https://example.com/avatar.png"
          },
          "content": {
            "text": "Full caption text...",
            "mediaUrls": ["https://example.com/image1.jpg"],
            "links": ["https://facebook.com/..."],
            "hashtags": ["#gauseva", "#gir"]
          },
          "metrics": {
            "likes": 150,
            "comments": 12,
            "shares": 5
          },
          "timestamp": "2025-12-11T10:00:00Z"
        }
      ]
    }
    ```
    *   **Note:** For "Detailed Post" view, the `content.text` should contain the full description. Frontend will handle "Read More" truncation if text length > limit.

---

## 5. User Profile

### 5.1 Get Profile
*   **Endpoint:** `GET /api/user/profile`
*   **Response:** User object details.
