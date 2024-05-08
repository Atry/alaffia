# Alaffia Challenge (Arthur Bayerlein)

Implements a solution for the challenge outlined here: https://antique-peach-0f3.notion.site/Senior-Engineer-Technical-Challenge-fd2d457f9dbf4b51a301cced093f71d9

## System Dependencies
- docker-compose

## Install Steps

- `npm install`
- `docker-compose up`
  - Services: app, postgres-database and shadow-database
- `npm run migrate`
  - It also seeds the database for this exercises test (for simplicity)

Access API webapp interface for basic local testing: http://localhost:5000/graphiql

## Stack

- NodeJS
  - Express framework
  - Typescript
- PostgreSQL
  - `graphile-migrate` for schema and function management / syncing
- GraphQL
  - `post-graphile` used to generate schema programatically (auto-extensible)
    - complex queries (I.e: usersByLocation) triggered by use of function for velocity and consistency
- DX utilities
  - `nodemon` with `node-ts` for auto-transpilation within containers
  - `graphile-migrate watch` for syncing DB schema changes 

## Queries that fulfill API requirements

PostGraphile is utilized in this project to automatically generate  the GraphQL API directly from the PostgreSQL database schema. This will make it inherently extensible. Since the API is defined programatically from the schema, the query syntax is defined by the resulting GraphQL schema. The following queries are the queries to fulfill the project requirements from the GraphQL schema produced by PostGraphile. 

### user

```graphql
query user($id: UUID!) {
  userById(id: $id) {
    id
    firstName
    lastName
    email
    role
    userFacilitiesByUserId {
      edges {
        node {
          facilityByFacilityId {
            id
            name
            createdAt
            locationsByFacilityId {
              nodes {
                address
                zip
                state
              }
            }
          }
        }
      }
    }
  }
}
```

Sample query-variables:
```json
{
  "id": "d6fbc5cf-8c87-442c-9bb9-cfaf4926fe01"
}
```

### usersByLocation

Note: In the assignment description, the users were spearate from locations. But since the users relate to locations via facilities, I decided to preserve the relationship here as well (maintainability).

```graphql
query usersByLocation($state: String, $zip: String, $address: String) {
  filterLocations(stateFilter: $state, zipFilter: $zip, addressFilter: $address) {
    edges {
      node {
        id
        facilityByFacilityId {
          createdAt
          id
          name
          userFacilitiesByFacilityId {
            edges {
              node {
                userByUserId {
                  email
                  firstName
                  id
                  lastName
                  createdAt
                  role
                }
              }
            }
          }
        }
      }
    }
  }
}
```

Sample query-variables:
```json
{
  "state": "CA",
  "zip": "90005"
}
```
