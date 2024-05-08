import request from "supertest";
import { createServer } from "http";
import { postgraphile } from "postgraphile";
import { Server } from "net";

const postGraphileMiddleware = postgraphile(
  process.env.DATABASE_URL as string,
  "public",
  {
    watchPg: true,
    graphiql: true,
    enhanceGraphiql: true,
  },
);

const app = createServer(postGraphileMiddleware);
let server: Server;

beforeAll((done) => {
  server = app.listen(4000, done); // Start the server at the beginning of the tests
});

afterAll((done) => {
  server.close(done); // Ensure the server is closed after the tests
});

describe("GraphQL Integration Tests", () => {
  it("User query returns the correct user and associated facilities", async () => {
    const query = `
      query GetUser($id: UUID!) {
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
    `;

    const response = await request(app)
      .post("/graphql")
      .send({
        query,
        variables: { id: "d6fbc5cf-8c87-442c-9bb9-cfaf4926fe01" },
      })
      .expect(200);

    expect(response.body.data.userById.firstName).toBe("John");
    expect(
      response.body.data.userById.userFacilitiesByUserId.edges.length,
    ).toBeGreaterThan(0);
  });

  it("usersByLocation returns correct data based on location filter", async () => {
    const query = `
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
    `;

    const response = await request(app)
      .post("/graphql")
      .send({
        query,
        variables: { state: "CA", zip: "90001", address: "Main St" },
      })
      .expect(200);

    expect(response.body.data.filterLocations.edges.length).toBeGreaterThan(0);
  });

  it("returns null for a non-existent user", async () => {
    const query = `
    query GetUser($id: UUID!) {
      userById(id: $id) {
        id
        firstName
      }
    }
  `;

    const response = await request(app)
      .post("/graphql")
      .send({
        query,
        variables: { id: "d6fbc5cf-8c87-442c-9bb9-cfaf4926fe04" },
      })
      .expect(200);

    expect(response.body.data.userById).toBeNull();
  });

  it("handles server errors gracefully", async () => {
    const query = `
    query {
      queryThatCausesServerError
    }
  `;

    await request(app).post("/graphql").send({ query }).expect(400);
  });
});
