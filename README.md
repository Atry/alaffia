# Alaffia Challenge (Arthur Bayerlein)

Implements a solution for the challenge outlined here: https://antique-peach-0f3.notion.site/Senior-Engineer-Technical-Challenge-fd2d457f9dbf4b51a301cced093f71d9

## System Dependencies

- Node v20.11.0 (npm v10.2.4)
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
  - `prettier`, because why not?
    - Naturally with more time I would use ESLint with agreed upon configs

## Queries that fulfill API requirements

PostGraphile is utilized in this project to automatically generate the GraphQL API directly from the PostgreSQL database schema. This will make it inherently extensible. Since the API is defined programatically from the schema, the query syntax is defined by the resulting GraphQL schema. The following queries are the queries to fulfill the project requirements from the GraphQL schema produced by PostGraphile.

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
  filterLocations(
    stateFilter: $state
    zipFilter: $zip
    addressFilter: $address
  ) {
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

## Integration tests

`npm run test`

For simplicity in this exercise, and since the stack makes the GraphQL schema heavily embedded to the PostgreSQL schema. I chose to use Jest to write a minimalistic integration test that runs directly against the database. Which has seeds in the migrations themselves.

For local DX for a bigger team, I would typically choose to keep the setup and teardown of integration tests in an isolated container with such that mutations don't remove the idempotency of the tests (they can be re-run without problems). I would also not add seeding to the `graphile-migrate` migration.

Due to the above, I also decided to skippe doing unit tests since the only application-level (service-layer) logic in the app is exposing Postgraphille. All business logic is embedded in the middleware Postgraphille example in this exercise.

If I needed to have more elaborate expanded queries that required individual Resolvers (with PostGraphille plugins or wrapped by Apollo), I would have added unit tests per resolver, for instance.
