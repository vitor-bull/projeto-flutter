const express = require('express');
const { createLogger, transports, format } = require('winston');
const { db, initializeDatabase } = require('./db/connection');
const userRoutes = require('./routes/userRoutes');

const app = express();
const PORT = 3001;

// Configuração do logger Winston
const logger = createLogger({
    level: 'info',
    format: format.combine(
        format.timestamp(),
        format.json()
    ),
    transports: [
        new transports.Console(),
        new transports.File({ filename: 'logs/server.log' }) // Logs serão salvos em um arquivo 'server.log'
    ]
});

app.use(express.json());
app.use('/users', userRoutes);

initializeDatabase().then(() => {
    app.listen(PORT, () => {
        logger.info(`Server is running on http://localhost:${PORT}`);
    });
}).catch(error => {
    logger.error('Failed to initialize database:', error);
});
