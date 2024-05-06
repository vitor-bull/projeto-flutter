const knex = require('knex');
const knexConfig = require('../knexfile.js').development;
const db = knex(knexConfig);

function logAction(actionDetails) {
  return db('log').insert({
      name: actionDetails.name,
      email: actionDetails.email,
      password: actionDetails.password,
      acao: actionDetails.acao,
      data: new Date()
  }).catch(err => console.error("Erro ao inserir no log:", err.message));
}

function initializeDatabase() {
    const { host, user, password, database } = knexConfig.connection;
    const dbWithoutDatabase = knex({
        client: knexConfig.client,
        connection: { host, user, password }
    });

    return dbWithoutDatabase.raw(`CREATE DATABASE IF NOT EXISTS ??`, [database])
        .then(() => dbWithoutDatabase.destroy())
        .then(() => {
            console.log(`Database ${database} is ready.`);
            return db.raw(`
                CREATE TABLE IF NOT EXISTS user(
                    id int NOT NULL AUTO_INCREMENT,
                    name varchar(150) NOT NULL,
                    email varchar(150) NOT NULL,
                    password varchar(256) NOT NULL,
                    PRIMARY KEY (id)
                );
            `);
        })
        .then(() => db.raw(`
            CREATE TABLE IF NOT EXISTS log(
                id INT AUTO_INCREMENT PRIMARY KEY,
                name varchar(150),
                email varchar(150),
                password varchar(256),
                acao TEXT,
                data TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        `))
        .then(() => db.raw (
            `USE db_projeto;`
        ))
        .then(() => {
            console.log('Tables `user` and `log` are ready.');
        })
        .catch(err => {
            console.error(`Failed to create database or tables: ${err.message}`);
            dbWithoutDatabase.destroy();
            process.exit(1);
        });
}

module.exports = { db, initializeDatabase, logAction };