
window.onload = function() {
  // Build a system
  var url = window.location.search.match(/url=([^&]+)/);
  if (url && url.length > 1) {
    url = decodeURIComponent(url[1]);
  } else {
    url = window.location.origin;
  }
  var options = {
  "swaggerDoc": {
    "openapi": "3.0.0",
    "info": {
      "title": "Cattle Management System (CMS) API",
      "version": "1.0.0",
      "description": "Comprehensive API documentation for all CMS microservices, aggregated via the Gateway."
    },
    "servers": [
      {
        "url": "https://cattle-management-system-1.onrender.com",
        "description": "API Gateway"
      }
    ],
    "components": {
      "securitySchemes": {
        "bearerAuth": {
          "type": "http",
          "scheme": "bearer",
          "bearerFormat": "JWT"
        }
      },
      "schemas": {
        "Animal": {
          "type": "object",
          "description": "Detailed profile of a bovine animal within the gaushala.",
          "properties": {
            "id": {
              "type": "string",
              "example": "65d1234567890abcdef12345",
              "description": "Unique internal identifier (MongoDB ObjectId)."
            },
            "name": {
              "type": "string",
              "minLength": 1,
              "example": "Laxmi",
              "description": "Name assigned to the animal."
            },
            "tagNumber": {
              "type": "string",
              "example": "TAG123",
              "description": "Physical tag number attached to the animal for identification."
            },
            "animalNumber": {
              "type": "string",
              "example": "C001",
              "description": "Internal gaushala serial number or sequence."
            },
            "gender": {
              "type": "string",
              "enum": [
                "MALE",
                "FEMALE"
              ],
              "example": "FEMALE",
              "description": "Biological gender of the animal."
            },
            "cowBreed": {
              "type": "string",
              "example": "Gir",
              "description": "Breed designation (e.g., Gir, Sahiwal, HL)."
            },
            "cowGroup": {
              "type": "string",
              "example": "Milk-Yielders",
              "description": "Logical group assignment for management purposes."
            },
            "birthDate": {
              "type": "string",
              "format": "date-time",
              "description": "Mandatory birth date (ISO 8601). Crucial for age and maturity calculations."
            },
            "adultDate": {
              "type": "string",
              "format": "date-time",
              "description": "Automatically calculated date (Birth date + 12 months) when treated as an adult."
            },
            "isPregnant": {
              "type": "boolean",
              "description": "Read-only; synced from Breeding service."
            },
            "isLactating": {
              "type": "boolean",
              "description": "Indicates if the cow is currently giving milk."
            },
            "isDryOff": {
              "type": "boolean",
              "description": "Indicates if the cow is in a dry period (not producing milk)."
            },
            "isHeifer": {
              "type": "boolean",
              "description": "A young female cow that has not yet had a calf. Under 1 year OR no pregnancy history."
            },
            "isRetired": {
              "type": "boolean",
              "description": "Marks animals that are removed from breeding/production cycles."
            },
            "parity": {
              "type": "integer",
              "minimum": 0,
              "description": "Number of times the cow has given birth (replaces lactationNumber)."
            },
            "bullView": {
              "type": "string",
              "description": "Specific breeding classification or characteristics for bulls."
            },
            "motherMilk": {
              "type": "number",
              "minimum": 0,
              "description": "Historical dairy performance of the animal's mother (in Liters)."
            },
            "grandmotherMilk": {
              "type": "number",
              "minimum": 0,
              "description": "Historical dairy performance of the animal's grandmother (in Liters)."
            },
            "isHandicapped": {
              "type": "boolean",
              "description": "Indicates physical impairment."
            },
            "handicapReason": {
              "type": "string",
              "description": "Brief explanation of the disability."
            },
            "acquisitionType": {
              "type": "string",
              "enum": [
                "BIRTH",
                "PURCHASE",
                "DONATION"
              ],
              "example": "PURCHASE",
              "description": "Source of entry into the gaushala."
            },
            "purchaseDate": {
              "type": "string",
              "format": "date-time",
              "description": "Required if acquired via PURCHASE (ISO 8601)."
            },
            "purchasedFrom": {
              "type": "string",
              "description": "Vendor or location of purchase."
            },
            "purchasePrice": {
              "type": "number",
              "minimum": 0,
              "example": 45000,
              "description": "Financial cost in local currency."
            },
            "ownerName": {
              "type": "string",
              "description": "Previous owner's name for documentation."
            },
            "ownerMobile": {
              "type": "string",
              "description": "Contact number of the previous owner."
            },
            "status": {
              "type": "string",
              "enum": [
                "ACTIVE",
                "SOLD",
                "DEAD",
                "DONATED"
              ],
              "example": "ACTIVE",
              "description": "Lifecycle availability of the animal."
            },
            "photoUrl": {
              "type": "string",
              "description": "Internal storage key for the primary image."
            },
            "viewUrl": {
              "type": "string",
              "format": "url",
              "description": "Secure temporary link for UI rendering (Expires quickly)."
            }
          }
        },
        "SellRecord": {
          "type": "object",
          "description": "Record of a successful animal sale transaction.",
          "required": [
            "animalId",
            "buyer",
            "mobileNumber",
            "amount"
          ],
          "properties": {
            "animalId": {
              "type": "string",
              "format": "mongo-id"
            },
            "buyer": {
              "type": "string",
              "minLength": 1,
              "example": "Ramesh Patel"
            },
            "mobileNumber": {
              "type": "string",
              "pattern": "^[6-9]\\d{9}$",
              "example": "9888776655"
            },
            "amount": {
              "type": "number",
              "minimum": 0,
              "example": 52000
            },
            "saleDate": {
              "type": "string",
              "format": "date-time"
            },
            "note": {
              "type": "string"
            }
          }
        },
        "DeathRecord": {
          "type": "object",
          "description": "Documentation for animal mortality.",
          "required": [
            "animalId",
            "deathDate",
            "reason"
          ],
          "properties": {
            "animalId": {
              "type": "string",
              "format": "mongo-id"
            },
            "deathDate": {
              "type": "string",
              "format": "date-time"
            },
            "reason": {
              "type": "string",
              "minLength": 1,
              "example": "Natural causes / Age"
            },
            "note": {
              "type": "string"
            }
          }
        },
        "DonationRecord": {
          "type": "object",
          "description": "Details regarding giving an animal away to another gaushala or person.",
          "required": [
            "animalId",
            "donee",
            "mobileNumber"
          ],
          "properties": {
            "animalId": {
              "type": "string",
              "format": "mongo-id"
            },
            "donee": {
              "type": "string",
              "minLength": 1,
              "description": "Recipient name."
            },
            "mobileNumber": {
              "type": "string",
              "pattern": "^[6-9]\\d{9}$",
              "example": "9876543210"
            },
            "photoUrl": {
              "type": "string",
              "description": "Key for any donation documentation or ceremony photo."
            }
          }
        },
        "ErrorResponse": {
          "type": "object",
          "properties": {
            "success": {
              "type": "boolean",
              "example": false
            },
            "errorCode": {
              "type": "string",
              "example": "UNAUTHORIZED"
            },
            "message": {
              "type": "string",
              "example": "Invalid authentication token"
            }
          }
        },
        "ValidationErrorResponse": {
          "type": "object",
          "properties": {
            "success": {
              "type": "boolean",
              "example": false
            },
            "errorCode": {
              "type": "string",
              "example": "VALIDATION_FAILED"
            },
            "message": {
              "type": "string",
              "example": "Request validation failed"
            },
            "errors": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "field": {
                    "type": "string",
                    "example": "mobileNumber"
                  },
                  "message": {
                    "type": "string",
                    "example": "Valid Indian mobile number is required"
                  }
                }
              }
            }
          }
        },
        "User": {
          "type": "object",
          "description": "Details of the authenticated user.",
          "properties": {
            "id": {
              "type": "string",
              "description": "Unique user identifier."
            },
            "mobileNumber": {
              "type": "string",
              "description": "Registered mobile number (Unique)."
            },
            "name": {
              "type": "string",
              "description": "User's full name."
            },
            "city": {
              "type": "string",
              "description": "User's home city."
            },
            "language": {
              "type": "string",
              "enum": [
                "ENGLISH",
                "GUJARATI",
                "HINDI"
              ],
              "description": "User's preferred interface language."
            },
            "gaushalas": {
              "type": "array",
              "items": {
                "$ref": "#/components/schemas/UserGaushala"
              },
              "description": "List of gaushalas where the user has a registered role."
            }
          }
        },
        "Gaushala": {
          "type": "object",
          "description": "Basic metadata of a Gaushala.",
          "properties": {
            "id": {
              "type": "string",
              "description": "Unique gaushala identifier."
            },
            "name": {
              "type": "string",
              "description": "Display name of the gaushala."
            },
            "city": {
              "type": "string",
              "description": "City where the gaushala is located."
            },
            "totalCattle": {
              "type": "integer",
              "description": "Total registered cattle count."
            }
          }
        },
        "UserGaushala": {
          "type": "object",
          "description": "Representation of a user's membership and role within a specific gaushala.",
          "properties": {
            "id": {
              "type": "string",
              "description": "Gaushala ID."
            },
            "name": {
              "type": "string",
              "description": "Gaushala Name."
            },
            "role": {
              "type": "string",
              "enum": [
                "OWNER",
                "MANAGER",
                "STAFF",
                "VETERINARIAN"
              ],
              "description": "User's designated role in this gaushala."
            },
            "city": {
              "type": "string",
              "description": "Gaushala City."
            }
          }
        },
        "Staff": {
          "type": "object",
          "description": "Details for adding/updating gaushala staff.",
          "required": [
            "mobileNumber",
            "name",
            "city",
            "role"
          ],
          "properties": {
            "mobileNumber": {
              "type": "string",
              "pattern": "^[6-9]\\d{9}$",
              "example": "9876543210"
            },
            "name": {
              "type": "string",
              "minLength": 1,
              "example": "Rahul Sharma"
            },
            "city": {
              "type": "string",
              "minLength": 1
            },
            "role": {
              "type": "string",
              "enum": [
                "MANAGER",
                "STAFF",
                "VETERINARIAN"
              ]
            }
          }
        },
        "HeatRecord": {
          "type": "object",
          "description": "Documentation of an animal's heat event and breeding attempt.",
          "required": [
            "animalId",
            "date",
            "breedingType"
          ],
          "properties": {
            "id": {
              "type": "string"
            },
            "animalId": {
              "type": "string",
              "format": "mongo-id",
              "description": "ID of the cow in heat."
            },
            "date": {
              "type": "string",
              "format": "date-time",
              "description": "Date and time when the heat was observed."
            },
            "breedingType": {
              "type": "string",
              "enum": [
                "NATURAL",
                "AI"
              ],
              "description": "AI: Artificial Insemination, NATURAL: Bull breeding."
            },
            "bullId": {
              "type": "string",
              "format": "mongo-id",
              "description": "Reference to the bull (if internal)."
            }
          }
        },
        "DryOffRecord": {
          "type": "object",
          "description": "Record of when a cow stopped giving milk (Dry-off period).",
          "required": [
            "animalId",
            "date",
            "reason"
          ],
          "properties": {
            "id": {
              "type": "string"
            },
            "animalId": {
              "type": "string"
            },
            "date": {
              "type": "string",
              "format": "date-time"
            },
            "reason": {
              "type": "string",
              "enum": [
                "ILLNESS",
                "LOW_YIELD",
                "MEDICATED",
                "OTHER"
              ]
            },
            "remarks": {
              "type": "string"
            }
          }
        },
        "ConceptionJourney": {
          "type": "object",
          "description": "Master record for a single pregnancy lifecycle from conception to delivery.",
          "required": [
            "animalId",
            "conceiveDate",
            "pregnancyType"
          ],
          "properties": {
            "id": {
              "type": "string"
            },
            "animalId": {
              "type": "string"
            },
            "conceiveDate": {
              "type": "string",
              "format": "date-time",
              "description": "Starting date of the conception period."
            },
            "pregnancyType": {
              "type": "string",
              "enum": [
                "NATURAL",
                "AI"
              ]
            },
            "currentStage": {
              "type": "string",
              "enum": [
                "INITIATED",
                "PD_CONFIRMED",
                "DRY_OFF",
                "DELIVERED",
                "ABORTED"
              ],
              "description": "Tracks the progress of the pregnancy."
            },
            "pdResult": {
              "type": "boolean",
              "description": "Result of the Pregnancy Diagnosis check."
            },
            "pdDate": {
              "type": "string",
              "format": "date-time"
            },
            "dryOffDate": {
              "type": "string",
              "format": "date-time"
            },
            "deliveryDate": {
              "type": "string",
              "format": "date-time"
            }
          }
        },
        "ParityRecord": {
          "type": "object",
          "description": "Historical record of a specific past parity (calving event).",
          "required": [
            "animalId",
            "parityNo",
            "deliveryDate",
            "pregnancyDate"
          ],
          "properties": {
            "id": {
              "type": "string"
            },
            "animalId": {
              "type": "string"
            },
            "parityNo": {
              "type": "integer",
              "minimum": 1,
              "description": "Sequence number of the birth (e.g. 1st calf, 2nd calf)."
            },
            "pregnancyDate": {
              "type": "string",
              "format": "date-time"
            },
            "deliveryDate": {
              "type": "string",
              "format": "date-time"
            },
            "calfId": {
              "type": "string",
              "format": "mongo-id",
              "description": "Link to the registered offspring profile."
            }
          }
        },
        "DiseaseMaster": {
          "type": "object",
          "description": "Reference record for a known bovine disease.",
          "properties": {
            "id": {
              "type": "string",
              "example": "65d1234567890abcdef12345"
            },
            "name": {
              "type": "string",
              "minLength": 1,
              "example": "Foot and Mouth Disease",
              "description": "Common name of the illness."
            }
          }
        },
        "VaccineMaster": {
          "type": "object",
          "description": "Reference record for available vaccines.",
          "properties": {
            "id": {
              "type": "string",
              "example": "65d1234567890abcdef12346"
            },
            "name": {
              "type": "string",
              "minLength": 1,
              "example": "FMD Vaccine",
              "description": "Commercial or scientific name of the vaccine."
            }
          }
        },
        "MedicalRecord": {
          "type": "object",
          "description": "Detailed entry for a veterinary visit or health check.",
          "required": [
            "animalId",
            "visitType",
            "visitDate",
            "medicalStatus"
          ],
          "properties": {
            "id": {
              "type": "string"
            },
            "animalId": {
              "type": "string",
              "format": "mongo-id",
              "description": "Host animal ID."
            },
            "visitType": {
              "type": "string",
              "enum": [
                "ILLNESS",
                "CHECKUP"
              ],
              "description": "Reason for the veterinary interaction."
            },
            "visitDate": {
              "type": "string",
              "format": "date-time",
              "description": "Precise date of the visit."
            },
            "visitNumber": {
              "type": "string",
              "description": "Internal visit sequence or token."
            },
            "vetId": {
              "type": "string",
              "format": "mongo-id",
              "description": "ID of the attending veterinarian (Managed in Auth/Gaushala)."
            },
            "diseaseId": {
              "type": "string",
              "format": "mongo-id",
              "description": "diagnosed disease (if visitType is ILLNESS)."
            },
            "medicalStatus": {
              "type": "string",
              "enum": [
                "SICK",
                "HEALTHY"
              ],
              "description": "Resulting health status after the visit."
            },
            "symptoms": {
              "type": "string",
              "description": "Observed signs of illness."
            },
            "treatment": {
              "type": "string",
              "description": "Prescribed medications or actions."
            }
          }
        },
        "VaccinationRecord": {
          "type": "object",
          "description": "Documentation for a single vaccine dose administration.",
          "required": [
            "animalId",
            "doseDate",
            "doseType",
            "vaccineId"
          ],
          "properties": {
            "id": {
              "type": "string"
            },
            "animalId": {
              "type": "string",
              "format": "mongo-id"
            },
            "doseDate": {
              "type": "string",
              "format": "date-time",
              "description": "Date of administration."
            },
            "doseType": {
              "type": "string",
              "enum": [
                "FIRST",
                "BOOSTER",
                "REPEAT"
              ],
              "description": "Placement in the vaccination cycle."
            },
            "vaccineId": {
              "type": "string",
              "format": "mongo-id",
              "description": "Reference to VaccineMaster."
            },
            "remark": {
              "type": "string"
            }
          }
        },
        "DewormingRecord": {
          "type": "object",
          "description": "Tracking for internal parasite treatments.",
          "required": [
            "animalId",
            "doseDate",
            "doseType"
          ],
          "properties": {
            "id": {
              "type": "string"
            },
            "animalId": {
              "type": "string",
              "format": "mongo-id"
            },
            "doseDate": {
              "type": "string",
              "format": "date-time"
            },
            "doseType": {
              "type": "string",
              "enum": [
                "INJECTION",
                "TABLET"
              ],
              "description": "Mode of administration."
            },
            "companyName": {
              "type": "string",
              "description": "Manufacturer of the dewormer."
            },
            "quantity": {
              "type": "string",
              "example": "500mg"
            },
            "vetId": {
              "type": "string",
              "format": "mongo-id"
            },
            "nextDoseDate": {
              "type": "string",
              "format": "date-time",
              "description": "Scheduled date for followup."
            }
          }
        },
        "MilkDistributionCategory": {
          "type": "object",
          "description": "Logical category for milk allocation (e.g., Home, Sell, Calf).",
          "required": [
            "name"
          ],
          "properties": {
            "id": {
              "type": "string"
            },
            "name": {
              "type": "string",
              "minLength": 1,
              "example": "Commercial Sale"
            }
          }
        },
        "FeedInventory": {
          "type": "object",
          "description": "Tracking of cattle feed stock levels.",
          "required": [
            "feedName",
            "quantity",
            "unit"
          ],
          "properties": {
            "id": {
              "type": "string"
            },
            "feedName": {
              "type": "string",
              "minLength": 1,
              "example": "Maize Silage"
            },
            "quantity": {
              "type": "number",
              "minimum": 0,
              "example": 500
            },
            "unit": {
              "type": "string",
              "enum": [
                "KG",
                "TON",
                "BAG"
              ],
              "example": "KG"
            },
            "lastUpdated": {
              "type": "string",
              "format": "date-time"
            }
          }
        },
        "MilkRecord": {
          "type": "object",
          "description": "Daily milk yield entry for an individual animal.",
          "required": [
            "animalId",
            "date",
            "morning",
            "evening"
          ],
          "properties": {
            "id": {
              "type": "string"
            },
            "animalId": {
              "type": "string",
              "format": "mongo-id"
            },
            "date": {
              "type": "string",
              "format": "date"
            },
            "morning": {
              "type": "number",
              "minimum": 0,
              "description": "Morning yield in Liters."
            },
            "evening": {
              "type": "number",
              "minimum": 0,
              "description": "Evening yield in Liters."
            },
            "total": {
              "type": "number",
              "description": "Read-only; calculated sum."
            }
          }
        },
        "DistributionRecord": {
          "type": "object",
          "description": "Allocation of daily milk yield to a specific category.",
          "required": [
            "categoryId",
            "date",
            "amount"
          ],
          "properties": {
            "id": {
              "type": "string"
            },
            "categoryId": {
              "type": "string",
              "format": "mongo-id"
            },
            "date": {
              "type": "string",
              "format": "date"
            },
            "amount": {
              "type": "number",
              "minimum": 0,
              "description": "Amount allocated in Liters."
            },
            "remarks": {
              "type": "string"
            }
          }
        }
      },
      "responses": {
        "UnauthorizedError": {
          "description": "Missing or invalid token.",
          "content": {
            "application/json": {
              "schema": {
                "$ref": "#/components/schemas/ErrorResponse"
              }
            }
          }
        },
        "ForbiddenError": {
          "description": "Permission denied.",
          "content": {
            "application/json": {
              "schema": {
                "$ref": "#/components/schemas/ErrorResponse"
              }
            }
          }
        },
        "InternalError": {
          "description": "Unexpected server error.",
          "content": {
            "application/json": {
              "schema": {
                "$ref": "#/components/schemas/ErrorResponse"
              }
            }
          }
        }
      },
      "parameters": {
        "GaushalaIdHeader": {
          "in": "header",
          "name": "gaushala-id",
          "required": true,
          "schema": {
            "type": "string",
            "description": "Multi-tenant scope identifier for the gaushala."
          }
        }
      }
    },
    "paths": {
      "/api/animal/groups": {
        "get": {
          "summary": "List logical groups",
          "description": "Returns only the names of all unique logical groups currently in use within the gaushala.",
          "tags": [
            "Animal Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Unique group name array."
            },
            "401": {
              "$ref": "#/components/responses/UnauthorizedError"
            }
          }
        },
        "post": {
          "summary": "Create new cow group",
          "description": "Manually adds a new group name to the selection list.",
          "tags": [
            "Animal Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "name"
                  ],
                  "properties": {
                    "name": {
                      "type": "string",
                      "minLength": 1,
                      "example": "High Producers"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Group created."
            },
            "400": {
              "$ref": "#/components/schemas/ValidationErrorResponse"
            }
          }
        }
      },
      "/api/animal/groups/{id}": {
        "patch": {
          "summary": "Rename group",
          "tags": [
            "Animal Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "name": {
                      "type": "string",
                      "minLength": 1
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Renamed."
            }
          }
        },
        "delete": {
          "summary": "Delete group",
          "description": "Removes a logical group from the gaushala catalog.",
          "tags": [
            "Animal Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Group deleted."
            }
          }
        }
      },
      "/api/animal/sell": {
        "post": {
          "summary": "Sell an animal",
          "description": "Records a sale transaction and updates the animal's status to 'SOLD'. Includes inventory removal.",
          "tags": [
            "Animal Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/SellRecord"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Sale recorded."
            },
            "400": {
              "description": "Validation error.",
              "content": {
                "application/json": {
                  "schema": {
                    "$ref": "#/components/schemas/ValidationErrorResponse"
                  }
                }
              }
            },
            "401": {
              "$ref": "#/components/responses/UnauthorizedError"
            }
          }
        }
      },
      "/api/animal/death": {
        "post": {
          "summary": "Mark animal as dead",
          "description": "Finalizes an animal's profile with death records and updates status to 'DEAD'.",
          "tags": [
            "Animal Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/DeathRecord"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Mortality documented."
            },
            "400": {
              "description": "Validation error."
            },
            "401": {
              "$ref": "#/components/responses/UnauthorizedError"
            }
          }
        }
      },
      "/api/animal/donation": {
        "post": {
          "summary": "Document donation",
          "description": "Changes animal status to 'DONATED' and records the recipient.",
          "tags": [
            "Animal Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/DonationRecord"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Donation archived."
            },
            "400": {
              "description": "Validation error."
            },
            "401": {
              "$ref": "#/components/responses/UnauthorizedError"
            }
          }
        }
      },
      "/api/animal/disposal/{type}/{id}": {
        "patch": {
          "summary": "Update disposal history",
          "description": "Adjusts existing sale, death, or donation records.",
          "tags": [
            "Animal Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "type",
              "required": true,
              "schema": {
                "type": "string",
                "enum": [
                  "sell",
                  "death",
                  "donation"
                ]
              }
            },
            {
              "in": "path",
              "name": "id",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Updated."
            },
            "400": {
              "description": "Validation error."
            },
            "401": {
              "$ref": "#/components/responses/UnauthorizedError"
            }
          }
        }
      },
      "/api/animal/add": {
        "post": {
          "summary": "Register a new cow or bull",
          "description": "Adds a new entry to the gaushala inventory. Automatically calculates 'adultDate'.",
          "tags": [
            "Animal Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true,
              "schema": {
                "type": "string"
              }
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/Animal",
                  "required": [
                    "gender",
                    "birthDate",
                    "acquisitionType"
                  ]
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Successfully added."
            },
            "400": {
              "description": "Validation error.",
              "content": {
                "application/json": {
                  "schema": {
                    "$ref": "#/components/schemas/ValidationErrorResponse"
                  }
                }
              }
            },
            "401": {
              "$ref": "#/components/responses/UnauthorizedError"
            },
            "500": {
              "$ref": "#/components/responses/InternalError"
            }
          }
        }
      },
      "/api/animal/cows": {
        "get": {
          "summary": "Advanced cow search and filtering",
          "description": "Retrieves a list of female animals with status-based filtering (e.g., searching for all pregnant cows).",
          "tags": [
            "Animal Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            },
            {
              "in": "query",
              "name": "filter",
              "schema": {
                "type": "string",
                "enum": [
                  "all",
                  "lactating",
                  "heifer",
                  "pregnant",
                  "dryoff",
                  "retired",
                  "calves"
                ]
              },
              "description": "Lifecycle and production state filtering."
            },
            {
              "in": "query",
              "name": "search",
              "description": "Partial match on name or tag number."
            },
            {
              "in": "query",
              "name": "page",
              "schema": {
                "type": "integer",
                "default": 1
              }
            },
            {
              "in": "query",
              "name": "limit",
              "schema": {
                "type": "integer",
                "default": 20
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Cow list with total meta."
            },
            "401": {
              "$ref": "#/components/responses/UnauthorizedError"
            }
          }
        }
      },
      "/api/animal/bulls": {
        "get": {
          "summary": "List bulls by status",
          "description": "Specialized endpoint for male animals with age and retirement filters.",
          "tags": [
            "Animal Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            },
            {
              "in": "query",
              "name": "filter",
              "schema": {
                "type": "string",
                "enum": [
                  "all",
                  "retired",
                  "calf"
                ]
              }
            },
            {
              "in": "query",
              "name": "page",
              "schema": {
                "type": "integer",
                "default": 1
              }
            },
            {
              "in": "query",
              "name": "limit",
              "schema": {
                "type": "integer",
                "default": 20
              }
            }
          ],
          "responses": {
            "200": {
              "description": "List of bulls."
            },
            "401": {
              "$ref": "#/components/responses/UnauthorizedError"
            }
          }
        }
      },
      "/api/animal/media/presigned-url": {
        "get": {
          "summary": "Secure upload URL",
          "description": "Retrieves a pre-authorized URL for uploading animal photos or disposal documentation directly to storage.",
          "tags": [
            "Animal Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "query",
              "name": "fileName",
              "required": true
            },
            {
              "in": "query",
              "name": "contentType",
              "required": true
            },
            {
              "in": "query",
              "name": "type",
              "schema": {
                "type": "string",
                "enum": [
                  "PHOTO",
                  "DISPOSAL",
                  "DOC"
                ]
              },
              "description": "Specific storage bucket/path."
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Upload instructions generated."
            },
            "401": {
              "$ref": "#/components/responses/UnauthorizedError"
            }
          }
        }
      },
      "/api/animal/{id}": {
        "get": {
          "summary": "Full animal profile",
          "description": "Retrieves all available data for a single animal by its primary ID.",
          "tags": [
            "Animal Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Multi-layered profile retrieved."
            },
            "401": {
              "$ref": "#/components/responses/UnauthorizedError"
            },
            "404": {
              "description": "Animal not found."
            }
          }
        }
      },
      "/api/animal/update/{id}": {
        "patch": {
          "summary": "Update profile markers",
          "description": "Allows modification of name, tag, status booleans, and other descriptive fields.",
          "tags": [
            "Animal Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/Animal"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Profile updated."
            },
            "400": {
              "description": "Validation error."
            },
            "401": {
              "$ref": "#/components/responses/UnauthorizedError"
            },
            "404": {
              "description": "Animal not found."
            }
          }
        }
      },
      "/api/auth/register": {
        "post": {
          "summary": "Register a new Gaushala Owner",
          "description": "Creates a new user profile and their primary gaushala. The registering user is automatically assigned the 'OWNER' role.",
          "tags": [
            "Auth Service"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "mobileNumber",
                    "password",
                    "name",
                    "city",
                    "gaushalaName"
                  ],
                  "properties": {
                    "mobileNumber": {
                      "type": "string",
                      "pattern": "^[6-9]\\d{9}$",
                      "example": "9876543210",
                      "description": "Valid 10-digit Indian mobile number."
                    },
                    "password": {
                      "type": "string",
                      "format": "password",
                      "minLength": 6,
                      "example": "Password@123",
                      "description": "Secure password (Min 6 characters)."
                    },
                    "name": {
                      "type": "string",
                      "minLength": 1,
                      "example": "Neel Raiyani"
                    },
                    "city": {
                      "type": "string",
                      "minLength": 1,
                      "example": "Rajkot"
                    },
                    "gaushalaName": {
                      "type": "string",
                      "minLength": 1,
                      "example": "Gopal Gaushala",
                      "description": "Name of the first gaushala to be created."
                    },
                    "totalCattle": {
                      "type": "integer",
                      "minimum": 0,
                      "example": 50,
                      "description": "Estimated initial cattle count."
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "User and Gaushala registered successfully."
            },
            "400": {
              "description": "Validation error or mobile number already registered.",
              "content": {
                "application/json": {
                  "schema": {
                    "oneOf": [
                      {
                        "$ref": "#/components/schemas/ValidationErrorResponse"
                      },
                      {
                        "$ref": "#/components/schemas/ErrorResponse"
                      }
                    ]
                  }
                }
              }
            },
            "500": {
              "$ref": "#/components/responses/InternalError"
            }
          }
        }
      },
      "/api/auth/login": {
        "post": {
          "summary": "Login to the system",
          "description": "Authenticates user credentials and returns a JWT token.",
          "tags": [
            "Auth Service"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "mobileNumber",
                    "password"
                  ],
                  "properties": {
                    "mobileNumber": {
                      "type": "string",
                      "pattern": "^[6-9]\\d{9}$",
                      "example": "9876543210"
                    },
                    "password": {
                      "type": "string",
                      "format": "password",
                      "example": "Password@123"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Login successful. Returns JWT."
            },
            "400": {
              "description": "Validation error.",
              "content": {
                "application/json": {
                  "schema": {
                    "$ref": "#/components/schemas/ValidationErrorResponse"
                  }
                }
              }
            },
            "401": {
              "description": "Invalid mobile number or password.",
              "content": {
                "application/json": {
                  "schema": {
                    "$ref": "#/components/schemas/ErrorResponse"
                  }
                }
              }
            }
          }
        }
      },
      "/api/auth/profile": {
        "get": {
          "summary": "Get current user profile",
          "description": "Retrieves the full user profile including their memberships across various gaushalas.",
          "tags": [
            "Auth Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "responses": {
            "200": {
              "description": "Profile data retrieved.",
              "content": {
                "application/json": {
                  "schema": {
                    "$ref": "#/components/schemas/User"
                  }
                }
              }
            },
            "401": {
              "description": "Missing or invalid token.",
              "content": {
                "application/json": {
                  "schema": {
                    "$ref": "#/components/schemas/ErrorResponse"
                  }
                }
              }
            }
          }
        }
      },
      "/api/auth/gaushala": {
        "post": {
          "summary": "Create an additional Gaushala",
          "description": "Creates a new gaushala and links it to the current user as an 'OWNER'.",
          "tags": [
            "Auth Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "name",
                    "city"
                  ],
                  "properties": {
                    "name": {
                      "type": "string",
                      "minLength": 1,
                      "example": "Krishna Gaushala"
                    },
                    "city": {
                      "type": "string",
                      "minLength": 1,
                      "example": "Ahmedabad"
                    },
                    "totalCattle": {
                      "type": "integer",
                      "minimum": 0,
                      "example": 20
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Additional gaushala created."
            },
            "400": {
              "description": "Validation error.",
              "content": {
                "application/json": {
                  "schema": {
                    "$ref": "#/components/schemas/ValidationErrorResponse"
                  }
                }
              }
            },
            "401": {
              "description": "Unauthorized."
            }
          }
        }
      },
      "/api/auth/gaushala/my": {
        "get": {
          "summary": "Get user's gaushalas",
          "description": "Returns a list of all gaushalas where the user holds a role (Owner, Manager, Staff, etc.).",
          "tags": [
            "Auth Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "responses": {
            "200": {
              "description": "List of gaushalas memberships.",
              "content": {
                "application/json": {
                  "schema": {
                    "type": "array",
                    "items": {
                      "$ref": "#/components/schemas/UserGaushala"
                    }
                  }
                }
              }
            },
            "401": {
              "$ref": "#/components/responses/UnauthorizedError"
            }
          }
        }
      },
      "/api/auth/forgot-password/send-otp": {
        "post": {
          "summary": "Send OTP for password reset",
          "description": "Sends a 4-digit verification code to the registered mobile number via SMS.",
          "tags": [
            "Auth Service"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "mobileNumber"
                  ],
                  "properties": {
                    "mobileNumber": {
                      "type": "string",
                      "pattern": "^[6-9]\\d{9}$",
                      "example": "9876543210"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "OTP successfully dispatched."
            },
            "400": {
              "description": "Validation error."
            },
            "404": {
              "description": "Mobile number not found.",
              "content": {
                "application/json": {
                  "schema": {
                    "$ref": "#/components/schemas/ErrorResponse"
                  }
                }
              }
            }
          }
        }
      },
      "/api/auth/forgot-password/verify": {
        "post": {
          "summary": "Verify OTP and Reset Password",
          "description": "Validates the 4-digit code and applies the new password to the user account.",
          "tags": [
            "Auth Service"
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "mobileNumber",
                    "otp",
                    "newPassword"
                  ],
                  "properties": {
                    "mobileNumber": {
                      "type": "string",
                      "pattern": "^[6-9]\\d{9}$",
                      "example": "9876543210"
                    },
                    "otp": {
                      "type": "string",
                      "minLength": 4,
                      "maxLength": 6,
                      "example": "1234"
                    },
                    "newPassword": {
                      "type": "string",
                      "format": "password",
                      "minLength": 6,
                      "example": "NewSecurePassword@123"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Password reset complete."
            },
            "400": {
              "description": "Invalid or expired OTP / Validation error.",
              "content": {
                "application/json": {
                  "schema": {
                    "oneOf": [
                      {
                        "$ref": "#/components/schemas/ValidationErrorResponse"
                      },
                      {
                        "$ref": "#/components/schemas/ErrorResponse"
                      }
                    ]
                  }
                }
              }
            }
          }
        }
      },
      "/api/auth/change-password": {
        "post": {
          "summary": "Force Change Password",
          "description": "Securely updates user password by verifying the existing (old) password.",
          "tags": [
            "Auth Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "oldPassword",
                    "newPassword"
                  ],
                  "properties": {
                    "oldPassword": {
                      "type": "string",
                      "format": "password",
                      "example": "Password@123"
                    },
                    "newPassword": {
                      "type": "string",
                      "format": "password",
                      "minLength": 6,
                      "example": "ChangedPassword@789"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Password updated."
            },
            "400": {
              "description": "Old password verification failed / Validation error.",
              "content": {
                "application/json": {
                  "schema": {
                    "oneOf": [
                      {
                        "$ref": "#/components/schemas/ValidationErrorResponse"
                      },
                      {
                        "$ref": "#/components/schemas/ErrorResponse"
                      }
                    ]
                  }
                }
              }
            },
            "401": {
              "$ref": "#/components/responses/UnauthorizedError"
            }
          }
        }
      },
      "/api/auth/settings": {
        "put": {
          "summary": "Update gaushala preferences",
          "description": "Modifies gaushala-specific settings like default application language. Requires MANAGER or OWNER role.",
          "tags": [
            "Auth Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true,
              "schema": {
                "type": "string"
              },
              "description": "Target Gaushala ID."
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "language": {
                      "type": "string",
                      "example": "GUJARATI",
                      "enum": [
                        "ENGLISH",
                        "GUJARATI",
                        "HINDI"
                      ]
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Settings saved."
            },
            "400": {
              "description": "Validation error."
            },
            "401": {
              "$ref": "#/components/responses/UnauthorizedError"
            },
            "403": {
              "description": "Permission denied for this gaushala.",
              "content": {
                "application/json": {
                  "schema": {
                    "$ref": "#/components/schemas/ErrorResponse"
                  }
                }
              }
            }
          }
        }
      },
      "/api/auth/staff": {
        "post": {
          "summary": "Add new staff member",
          "description": "Creates a link between an existing user and a gaushala with a specific role.",
          "tags": [
            "Auth Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/Staff"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Staff added."
            },
            "400": {
              "$ref": "#/components/schemas/ValidationErrorResponse"
            }
          }
        },
        "get": {
          "summary": "List gaushala staff",
          "description": "Retrieves all users who hold a role in the specified gaushala.",
          "tags": [
            "Auth Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Staff list."
            }
          }
        }
      },
      "/api/auth/staff/{userId}": {
        "patch": {
          "summary": "Update staff role",
          "tags": [
            "Auth Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "userId",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "role": {
                      "type": "string",
                      "enum": [
                        "MANAGER",
                        "STAFF",
                        "VETERINARIAN"
                      ]
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Role updated."
            }
          }
        },
        "delete": {
          "summary": "Remove staff member",
          "description": "Revokes a user's access to the gaushala.",
          "tags": [
            "Auth Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "userId",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Staff member removed."
            }
          }
        }
      },
      "/api/breeding/media/presigned-url": {
        "get": {
          "summary": "Get upload URL for breeding media",
          "description": "Provides a temporary link for uploading pregnancy or delivery photos.",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "query",
              "name": "fileName",
              "required": true
            },
            {
              "in": "query",
              "name": "fileType",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Presigned URL generated."
            }
          }
        }
      },
      "/api/breeding/heat": {
        "post": {
          "summary": "Record heat observation",
          "description": "Registers a new heat event. Updates the animal's breeding status tokens.",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/HeatRecord"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Event recorded."
            },
            "400": {
              "description": "Validation error.",
              "content": {
                "application/json": {
                  "schema": {
                    "$ref": "#/components/schemas/ValidationErrorResponse"
                  }
                }
              }
            },
            "401": {
              "$ref": "#/components/responses/UnauthorizedError"
            }
          }
        },
        "get": {
          "summary": "Animal heat history",
          "description": "Lists all past heat records for a specific animal.",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            },
            {
              "in": "query",
              "name": "animalId",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "List of records."
            },
            "401": {
              "$ref": "#/components/responses/UnauthorizedError"
            }
          }
        }
      },
      "/api/breeding/heat/eligible": {
        "get": {
          "summary": "Animals ready for heat",
          "description": "Returns a list of cows eligible for a new heat record.",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "List of animals."
            }
          }
        }
      },
      "/api/breeding/heat/{id}": {
        "patch": {
          "summary": "Update heat entry",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/HeatRecord"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Updated."
            },
            "400": {
              "$ref": "#/components/schemas/ValidationErrorResponse"
            },
            "401": {
              "$ref": "#/components/responses/UnauthorizedError"
            }
          }
        },
        "delete": {
          "summary": "Remove heat record",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Deleted."
            }
          }
        }
      },
      "/api/breeding/dry-off": {
        "post": {
          "summary": "Mark animal as Dry",
          "description": "Records a dry-off period for a cow. Updates 'isLactating' to false.",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/DryOffRecord"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Status updated."
            },
            "400": {
              "$ref": "#/components/schemas/ValidationErrorResponse"
            },
            "401": {
              "$ref": "#/components/responses/UnauthorizedError"
            }
          }
        },
        "get": {
          "summary": "Dry-off history",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            },
            {
              "in": "query",
              "name": "animalId",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "History retrieved."
            },
            "401": {
              "$ref": "#/components/responses/UnauthorizedError"
            }
          }
        }
      },
      "/api/breeding/dry-off/eligible": {
        "get": {
          "summary": "Eligible for Dry-off",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Dropdown list."
            }
          }
        }
      },
      "/api/breeding/dry-off/{id}": {
        "patch": {
          "summary": "Correct dry-off record",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/DryOffRecord"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Corrected."
            },
            "400": {
              "$ref": "#/components/schemas/ValidationErrorResponse"
            }
          }
        },
        "delete": {
          "summary": "Remove dry-off record",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Record removed."
            }
          }
        }
      },
      "/api/breeding/parity": {
        "post": {
          "summary": "Add historical parity",
          "description": "Manually adds a past birth record for historical tracking.",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/ParityRecord"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Record added."
            }
          }
        }
      },
      "/api/breeding/parity/{animalId}": {
        "get": {
          "summary": "Full birth history",
          "description": "Retrieves all recorded calving events for an animal.",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "animalId",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Parity timeline."
            }
          }
        }
      },
      "/api/breeding/parity/{id}": {
        "patch": {
          "summary": "Update parity record",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/ParityRecord"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Parity entry updated."
            }
          }
        }
      },
      "/api/breeding/journey/initiate": {
        "post": {
          "summary": "Start a new pregnancy lifecycle",
          "description": "Initializes a journey. Updates cow status to 'isPregnant: true' and 'isHeifer: false'.",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/ConceptionJourney",
                  "required": [
                    "animalId",
                    "conceiveDate",
                    "pregnancyType"
                  ]
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Journey started."
            },
            "400": {
              "description": "Cow already in an active journey or validation error."
            }
          }
        }
      },
      "/api/breeding/journey/list": {
        "get": {
          "summary": "List all active journeys",
          "description": "Returns a global view of current pregnancies in the gaushala.",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Progress list."
            }
          }
        }
      },
      "/api/breeding/journey/eligible-cows": {
        "get": {
          "summary": "Get Eligible Cows for Journeys",
          "description": "Returns cows that are currently NOT in an active pregnancy journey and are of breeding age.",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "List of cows."
            }
          }
        }
      },
      "/api/breeding/journey/eligible-dry-off": {
        "get": {
          "summary": "Get Cows for Journey Dry-off",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Eligible cows list."
            }
          }
        }
      },
      "/api/breeding/journey/{id}": {
        "get": {
          "summary": "Journey Status Details",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Multi-stage breakdown."
            }
          }
        },
        "put": {
          "summary": "Correct initiation details",
          "description": "Allows fixing date/type after a journey has started.",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/ConceptionJourney"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Corrected."
            }
          }
        },
        "delete": {
          "summary": "Cancel pregnancy journey",
          "description": "Removes the journey record and resets cow's pregnancy status.",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Journey terminated."
            }
          }
        }
      },
      "/api/breeding/journey/{id}/confirm": {
        "patch": {
          "summary": "Confirm pregnancy (PD)",
          "description": "Documents the results of the Pregnancy Diagnosis. If `pdResult` is false, the journey ends as ABORTED.",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "pdResult",
                    "pdDate"
                  ],
                  "properties": {
                    "pdResult": {
                      "type": "boolean"
                    },
                    "pdDate": {
                      "type": "string",
                      "format": "date-time"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Result saved."
            }
          }
        }
      },
      "/api/breeding/journey/{id}/dry-off": {
        "patch": {
          "summary": "Record journey dry-off",
          "description": "Links a dry-off date to the active pregnancy journey.",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "dryOffDate"
                  ],
                  "properties": {
                    "dryOffDate": {
                      "type": "string",
                      "format": "date-time"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Stage updated to DRY_OFF."
            }
          }
        }
      },
      "/api/breeding/journey/{id}/deliver": {
        "patch": {
          "summary": "Record birth and close journey",
          "description": "CRITICAL: This atomic operation records the delivery outcome, increments the cow's parity, updates isPregnant/isLactating, and automatically registers the new calf in the Animal service.",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "deliveryDate",
                    "calfStatus",
                    "calfGender"
                  ],
                  "properties": {
                    "deliveryDate": {
                      "type": "string",
                      "format": "date-time"
                    },
                    "calfStatus": {
                      "type": "string",
                      "enum": [
                        "ALIVE",
                        "DEAD",
                        "ABORTED"
                      ]
                    },
                    "calfGender": {
                      "type": "string",
                      "enum": [
                        "MALE",
                        "FEMALE"
                      ]
                    },
                    "calfName": {
                      "type": "string"
                    },
                    "calfTagNumber": {
                      "type": "string"
                    },
                    "calfBreed": {
                      "type": "string"
                    },
                    "calfGroup": {
                      "type": "string"
                    },
                    "calfAppearance": {
                      "type": "string"
                    },
                    "calfWeight": {
                      "type": "number"
                    },
                    "deliveryPhoto": {
                      "type": "string"
                    },
                    "calfPhoto": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Delivery recorded and calf registered successfully."
            }
          }
        }
      },
      "/api/breeding/bulls/eligible": {
        "get": {
          "summary": "Get Breeding Bulls",
          "description": "Returns a list of bulls available for NATUAL breeding selection.",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "List of bulls for dropdown."
            }
          }
        }
      },
      "/api/breeding/lineage/{id}": {
        "get": {
          "summary": "Get children list",
          "description": "Retrieves all registered calves birthed by the specified animal.",
          "tags": [
            "Breeding Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Children profiles."
            }
          }
        }
      },
      "/api/health/master/diseases": {
        "get": {
          "summary": "List all cataloged diseases",
          "description": "Retrieves the global master list of diseases for selection in records.",
          "tags": [
            "Health Service"
          ],
          "responses": {
            "200": {
              "description": "Disease array."
            }
          }
        },
        "post": {
          "summary": "Add to disease catalog",
          "description": "Creates a new disease master record for use across the platform.",
          "tags": [
            "Health Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "name"
                  ],
                  "properties": {
                    "name": {
                      "type": "string",
                      "minLength": 1,
                      "example": "Lumpy Skin Disease"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Master entry created."
            },
            "400": {
              "description": "Validation error.",
              "content": {
                "application/json": {
                  "schema": {
                    "$ref": "#/components/schemas/ValidationErrorResponse"
                  }
                }
              }
            }
          }
        }
      },
      "/api/health/master/vaccines": {
        "get": {
          "summary": "List all vaccines",
          "description": "Retrieves the global master list of available vaccinations.",
          "tags": [
            "Health Service"
          ],
          "responses": {
            "200": {
              "description": "Vaccine array."
            }
          }
        },
        "post": {
          "summary": "Add to vaccine catalog",
          "description": "Creates a new vaccine master entry.",
          "tags": [
            "Health Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "name"
                  ],
                  "properties": {
                    "name": {
                      "type": "string",
                      "minLength": 1,
                      "example": "Brucellosis Vaccine"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Master entry created."
            },
            "400": {
              "$ref": "#/components/schemas/ValidationErrorResponse"
            }
          }
        }
      },
      "/api/health/medical": {
        "post": {
          "summary": "Record medical encounter",
          "description": "Documents a physical checkup or illness treatment. Updates the animal's internal health flags.",
          "tags": [
            "Health Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "$ref": "#/components/parameters/GaushalaIdHeader"
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/MedicalRecord"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Encounter archived."
            },
            "400": {
              "description": "Validation error.",
              "content": {
                "application/json": {
                  "schema": {
                    "$ref": "#/components/schemas/ValidationErrorResponse"
                  }
                }
              }
            }
          }
        }
      },
      "/api/health/medical/{id}": {
        "patch": {
          "summary": "Update medical record",
          "description": "Modifies symptoms, treatment, or vet details for an existing record.",
          "tags": [
            "Health Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "name": "id",
              "in": "path",
              "required": true,
              "schema": {
                "type": "string",
                "format": "mongo-id"
              }
            },
            {
              "$ref": "#/components/parameters/GaushalaIdHeader"
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/MedicalRecord"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Changes saved."
            },
            "400": {
              "$ref": "#/components/schemas/ValidationErrorResponse"
            }
          }
        }
      },
      "/api/health/medical/animal/{animalId}": {
        "get": {
          "summary": "Animal health history",
          "description": "Retrieves all medical/encounter records for a specific animal.",
          "tags": [
            "Health Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "$ref": "#/components/parameters/GaushalaIdHeader"
            },
            {
              "in": "path",
              "name": "animalId",
              "required": true,
              "schema": {
                "type": "string",
                "format": "mongo-id"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "History retrieved."
            }
          }
        }
      },
      "/api/health/vaccination": {
        "post": {
          "summary": "Log a vaccination dose",
          "description": "Registers a specific dose against an animal and the global vaccine catalog.",
          "tags": [
            "Health Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "$ref": "#/components/parameters/GaushalaIdHeader"
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/VaccinationRecord"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Dose documented."
            },
            "400": {
              "$ref": "#/components/schemas/ValidationErrorResponse"
            }
          }
        }
      },
      "/api/health/vaccination/{id}": {
        "patch": {
          "summary": "Adjust vaccination record",
          "description": "Updates dose type or remarks for an existing vaccination entry.",
          "tags": [
            "Health Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "name": "id",
              "in": "path",
              "required": true,
              "schema": {
                "type": "string",
                "format": "mongo-id"
              }
            },
            {
              "$ref": "#/components/parameters/GaushalaIdHeader"
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/VaccinationRecord"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Updated."
            },
            "400": {
              "$ref": "#/components/schemas/ValidationErrorResponse"
            }
          }
        }
      },
      "/api/health/vaccination/animal/{animalId}": {
        "get": {
          "summary": "Vaccination timeline",
          "description": "Retrieves all doses and booster shots recorded for an animal.",
          "tags": [
            "Health Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "$ref": "#/components/parameters/GaushalaIdHeader"
            },
            {
              "in": "path",
              "name": "animalId",
              "required": true,
              "schema": {
                "type": "string",
                "format": "mongo-id"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Timeline array."
            }
          }
        }
      },
      "/api/health/deworming": {
        "get": {
          "summary": "List all deworming actions",
          "description": "Retrieves a global list of recent deworming records in the gaushala.",
          "tags": [
            "Health Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "$ref": "#/components/parameters/GaushalaIdHeader"
            }
          ],
          "responses": {
            "200": {
              "description": "Global list."
            }
          }
        },
        "post": {
          "summary": "Individual deworming",
          "description": "Records a single deworming treatment for one animal.",
          "tags": [
            "Health Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "$ref": "#/components/parameters/GaushalaIdHeader"
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/DewormingRecord"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Dose recorded."
            },
            "400": {
              "$ref": "#/components/schemas/ValidationErrorResponse"
            }
          }
        }
      },
      "/api/health/deworming/bulk": {
        "post": {
          "summary": "Batch deworming",
          "description": "Efficiently records a shared deworming event for a group of animals.",
          "tags": [
            "Health Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "$ref": "#/components/parameters/GaushalaIdHeader"
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "animalIds",
                    "doseDate",
                    "doseType"
                  ],
                  "properties": {
                    "animalIds": {
                      "type": "array",
                      "minItems": 1,
                      "items": {
                        "type": "string",
                        "format": "mongo-id"
                      },
                      "description": "Subset of animal IDs treated."
                    },
                    "doseDate": {
                      "type": "string",
                      "format": "date-time"
                    },
                    "doseType": {
                      "type": "string",
                      "enum": [
                        "INJECTION",
                        "TABLET"
                      ]
                    },
                    "companyName": {
                      "type": "string"
                    },
                    "quantity": {
                      "type": "string"
                    },
                    "vetId": {
                      "type": "string",
                      "format": "mongo-id"
                    },
                    "nextDoseDate": {
                      "type": "string",
                      "format": "date-time"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "All individual records created atomically."
            },
            "400": {
              "$ref": "#/components/schemas/ValidationErrorResponse"
            }
          }
        }
      },
      "/api/health/deworming/{id}": {
        "patch": {
          "summary": "Adjust deworming record",
          "tags": [
            "Health Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "name": "id",
              "in": "path",
              "required": true,
              "schema": {
                "type": "string",
                "format": "mongo-id"
              }
            },
            {
              "$ref": "#/components/parameters/GaushalaIdHeader"
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/DewormingRecord"
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Corrected."
            },
            "400": {
              "$ref": "#/components/schemas/ValidationErrorResponse"
            }
          }
        }
      },
      "/api/health/deworming/animal/{animalId}": {
        "get": {
          "summary": "Animal Deworming History",
          "tags": [
            "Health Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "animalId",
              "required": true,
              "schema": {
                "type": "string",
                "format": "mongo-id"
              }
            },
            {
              "$ref": "#/components/parameters/GaushalaIdHeader"
            }
          ],
          "responses": {
            "200": {
              "description": "Personal history."
            }
          }
        }
      },
      "/api/health/timeline/animal/{animalId}": {
        "get": {
          "summary": "Integrated Health Passport",
          "description": "Returns a chronological merged feed of ALL health interactions: Medical visits, Vaccinations, and Deworming doses.",
          "tags": [
            "Health Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "name": "animalId",
              "in": "path",
              "required": true,
              "schema": {
                "type": "string",
                "format": "mongo-id"
              }
            },
            {
              "$ref": "#/components/parameters/GaushalaIdHeader"
            }
          ],
          "responses": {
            "200": {
              "description": "Full chronological health timeline."
            }
          }
        }
      },
      "/api/production/categories": {
        "get": {
          "summary": "List distribution categories",
          "tags": [
            "Production Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Category list."
            }
          }
        },
        "post": {
          "summary": "Create milk category",
          "tags": [
            "Production Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/MilkDistributionCategory"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Category added."
            }
          }
        }
      },
      "/api/production/categories/{id}": {
        "patch": {
          "summary": "Rename category",
          "tags": [
            "Production Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "name": {
                      "type": "string",
                      "minLength": 1
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Category updated."
            }
          }
        },
        "delete": {
          "summary": "Remove distribution category",
          "tags": [
            "Production Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Deleted."
            }
          }
        }
      },
      "/api/production/inventory": {
        "get": {
          "summary": "View feed stock",
          "tags": [
            "Production Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Inventory list."
            }
          }
        }
      },
      "/api/production/inventory/update": {
        "post": {
          "summary": "Add/Update feed stock",
          "description": "Upserts feed inventory based on name.",
          "tags": [
            "Production Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/FeedInventory"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Stock updated."
            }
          }
        }
      },
      "/api/production/yields": {
        "post": {
          "summary": "Log daily milk yield",
          "description": "Records morning and evening production for one animal.",
          "tags": [
            "Production Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/MilkRecord"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Yield recorded."
            },
            "400": {
              "$ref": "#/components/schemas/ValidationErrorResponse"
            }
          }
        },
        "get": {
          "summary": "List daily yields",
          "tags": [
            "Production Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "History retrieved."
            }
          }
        }
      },
      "/api/production/yields/bulk": {
        "post": {
          "summary": "Bulk milk logging",
          "description": "Records yields for multiple animals for a specific date.",
          "tags": [
            "Production Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "required": [
                    "date",
                    "records"
                  ],
                  "properties": {
                    "date": {
                      "type": "string",
                      "format": "date"
                    },
                    "records": {
                      "type": "array",
                      "items": {
                        "type": "object",
                        "required": [
                          "animalId",
                          "morning",
                          "evening"
                        ],
                        "properties": {
                          "animalId": {
                            "type": "string"
                          },
                          "morning": {
                            "type": "number"
                          },
                          "evening": {
                            "type": "number"
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Records saved."
            }
          }
        }
      },
      "/api/production/yields/{id}": {
        "patch": {
          "summary": "Update yield entry",
          "tags": [
            "Production Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Updated."
            }
          }
        },
        "delete": {
          "summary": "Remove yield entry",
          "tags": [
            "Production Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Deleted."
            }
          }
        }
      },
      "/api/production/distribution": {
        "post": {
          "summary": "Allocate milk",
          "description": "Assigns a quantity of the day's total harvest to a specific purpose.",
          "tags": [
            "Production Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/DistributionRecord"
                }
              }
            }
          },
          "responses": {
            "201": {
              "description": "Allocation saved."
            }
          }
        },
        "get": {
          "summary": "List allocations",
          "tags": [
            "Production Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "List retrieved."
            }
          }
        }
      },
      "/api/production/distribution/{id}": {
        "patch": {
          "summary": "Correct allocation",
          "tags": [
            "Production Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "requestBody": {
            "required": true,
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "amount": {
                      "type": "number"
                    },
                    "remarks": {
                      "type": "string"
                    }
                  }
                }
              }
            }
          },
          "responses": {
            "200": {
              "description": "Updated."
            }
          }
        },
        "delete": {
          "summary": "Remove allocation",
          "tags": [
            "Production Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "id",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Removed."
            }
          }
        }
      },
      "/api/production/reports/daily": {
        "get": {
          "summary": "Daily production summary",
          "tags": [
            "Production Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            },
            {
              "in": "query",
              "name": "date",
              "required": true,
              "schema": {
                "type": "string",
                "format": "date"
              }
            }
          ],
          "responses": {
            "200": {
              "description": "Totals for the day."
            }
          }
        }
      },
      "/api/production/reports/monthly": {
        "get": {
          "summary": "Monthly production trends",
          "tags": [
            "Production Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            },
            {
              "in": "query",
              "name": "month",
              "required": true,
              "description": "Month number (1-12)"
            },
            {
              "in": "query",
              "name": "year",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Monthly aggregate data."
            }
          }
        }
      },
      "/api/production/reports/cow/{animalId}": {
        "get": {
          "summary": "Individual production history",
          "tags": [
            "Production Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "path",
              "name": "animalId",
              "required": true
            },
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Animal-wise yield data."
            }
          }
        }
      },
      "/api/production/reports/distribution": {
        "get": {
          "summary": "Allocation breakdown report",
          "tags": [
            "Production Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            },
            {
              "in": "query",
              "name": "startDate"
            },
            {
              "in": "query",
              "name": "endDate"
            }
          ],
          "responses": {
            "200": {
              "description": "Category-wise distribution totals."
            }
          }
        }
      },
      "/api/production/reports/parity": {
        "get": {
          "summary": "Yield by parity report",
          "description": "Compares milk production performance based on the cow's parity (1st calf vs 5th calf).",
          "tags": [
            "Production Service"
          ],
          "security": [
            {
              "bearerAuth": []
            }
          ],
          "parameters": [
            {
              "in": "header",
              "name": "gaushala-id",
              "required": true
            }
          ],
          "responses": {
            "200": {
              "description": "Parity performance metrics."
            }
          }
        }
      }
    },
    "tags": [
      {
        "name": "Animal Service",
        "description": "Comprehensive cattle management including health profiles, birth records, and disposal tracking via the Gateway."
      },
      {
        "name": "Auth Service",
        "description": "User authentication, registration, profile management, and Gaushala selection."
      },
      {
        "name": "Breeding Service",
        "description": "Animal breeding lifecycle management, including heat records, dry-off periods, and conception journeys."
      },
      {
        "name": "Health Service",
        "description": "Animal health lifecycle management, including disease tracking, vaccinations, medical history, and deworming."
      },
      {
        "name": "Production Service",
        "description": "Milk production tracking, inventory management, and allocation via the Gateway."
      }
    ]
  },
  "customOptions": {}
};
  url = options.swaggerUrl || url
  var urls = options.swaggerUrls
  var customOptions = options.customOptions
  var spec1 = options.swaggerDoc
  var swaggerOptions = {
    spec: spec1,
    url: url,
    urls: urls,
    dom_id: '#swagger-ui',
    deepLinking: true,
    presets: [
      SwaggerUIBundle.presets.apis,
      SwaggerUIStandalonePreset
    ],
    plugins: [
      SwaggerUIBundle.plugins.DownloadUrl
    ],
    layout: "StandaloneLayout"
  }
  for (var attrname in customOptions) {
    swaggerOptions[attrname] = customOptions[attrname];
  }
  var ui = SwaggerUIBundle(swaggerOptions)

  if (customOptions.oauth) {
    ui.initOAuth(customOptions.oauth)
  }

  if (customOptions.preauthorizeApiKey) {
    const key = customOptions.preauthorizeApiKey.authDefinitionKey;
    const value = customOptions.preauthorizeApiKey.apiKeyValue;
    if (!!key && !!value) {
      const pid = setInterval(() => {
        const authorized = ui.preauthorizeApiKey(key, value);
        if(!!authorized) clearInterval(pid);
      }, 500)

    }
  }

  if (customOptions.authAction) {
    ui.authActions.authorize(customOptions.authAction)
  }

  window.ui = ui
}
