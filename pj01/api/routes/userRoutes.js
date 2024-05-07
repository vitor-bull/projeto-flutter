const express = require('express');
const router = express.Router();
const { findUserByEmail, addUser, validateUser } = require('../models/userModel');
const apiKey = require('../api_key.json').key;
const { logAction } = require('../db/connection');
const { createLogger, transports, format } = require('winston');

// Configuração do logger Winston para as rotas de usuário
const logger = createLogger({
    level: 'info',
    format: format.combine(
        format.timestamp(),
        format.json()
    ),
    transports: [
        new transports.File({ filename: 'logs/userRoutes.log' }) // Logs serão salvos em um arquivo 'userRoutes.log'
    ]
});

router.use((req, res, next) => {
    if (req.query.apiKey !== apiKey) {
        logAction({
            name: '',
            email: '',
            acao: 'Chave API inválida'
        });
        logger.error('Chave API inválida'); // Log de erro
        return res.status(401).json({ error: 'Api Key inválida' });
    }
    next();
});

// POST /users/register
router.post('/register', async (req, res) => {
    const { name, email, password } = req.body;
    if (!name || !email || !password) {
        logAction({
            name,
            email,
            acao: 'Dados incompletos no cadastro'
        });
        logger.error('Dados incompletos no cadastro'); // Log de erro
        return res.status(400).json({ error: 'Todos os campos são necessários' });
    }
    try {
        const existingUser = await findUserByEmail(email);
        if (existingUser) {
            logAction({
                name,
                email,
                acao: 'Tentativa de cadastro com e-mail já existente'
            });
            logger.error('Tentativa de cadastro com e-mail já existente'); // Log de erro
            return res.status(409).json({ error: 'Já existe um usuário com este e-mail' });
        }
        await addUser(name, email, password);
        logger.info('Usuário cadastrado com sucesso'); // Log de informação
        return res.status(201).json({ message: 'Usuário cadastrado com sucesso' });
    } catch (error) {
        logAction({
            name,
            email,
            acao: `Erro ao tentar cadastrar usuário: ${error.message}`
        });
        logger.error(`Erro ao tentar cadastrar usuário: ${error.message}`); // Log de erro
        return res.status(500).json({ error: error.message });
    }
});

// POST /users/login
router.post('/login', async (req, res) => {
    const { email, password } = req.body;
    try {
        console.log(email, password);
        const isValid = await validateUser(email, password);
        if (!isValid) {
            logAction({
                name: '',
                email,
                acao: 'E-mail ou senha inválida no login'
            });
            logger.error('E-mail ou senha inválida no login'); // Log de erro
            return res.status(401).json({ error: 'E-mail ou senha inválida' });
        } else {
            logAction({
                name: '',
                email,
                acao: 'Login bem-sucedido'
            });
            logger.info('Login bem-sucedido'); // Log de informação
            return res.status(200).json({ message: 'Login bem-sucedido' });
        }
    } catch (error) {
        logAction({
            name: '',
            email,
            acao: `Erro ao tentar fazer login: ${error.message}`
        });
        logger.error(`Erro ao tentar fazer login: ${error.message}`); // Log de erro
        return res.status(500).json({ error: error.message });
    }
});



module.exports = router;
