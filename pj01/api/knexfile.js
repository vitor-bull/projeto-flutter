module.exports = {
  development: {
    client: 'mysql2',
    connection: {
      host: 'localhost',
      port: 3306,
      user: 'root',
      password: 'sysadm',
      database: 'db_projeto'
    },
    migrations: {
      tableName: 'knex_migrations'
    }
  }
};
