import express from 'express';
import { postgraphile } from 'postgraphile';

const app = express();
const DATABASE_URL = process.env.DATABASE_URL || 'postgres://postgres:password@localhost/alaffia_db';
const SCHEMA = 'public';

app.use(
    postgraphile(
        DATABASE_URL,
        SCHEMA,
        {
            watchPg: true,
            graphiql: true,
            enhanceGraphiql: true,
        }
    )
);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () : void => {
    console.log(`Server is running on http://localhost:${PORT}/graphiql`);
});
