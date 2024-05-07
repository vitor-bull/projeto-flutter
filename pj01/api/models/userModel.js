const { db, logAction } = require('../db/connection');
const CryptoJS = require('crypto-js');
const bcrypt = require('bcrypt');

async function findUserByEmail(email) {
  try {
    return await db('user').where({ email }).first();
  } catch (error) {
    console.error("Erro ao buscar usuário por e-mail:", error);
    throw error;
  }
}

async function addUser(name, email, password) {
  try {
    console.log("Recebendo solicitação para adicionar novo usuário:");
    console.log("Nome:", name);
    console.log("Email:", email);

    // Hash a senha antes de adicioná-la ao banco de dados
    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = { name, email, password: hashedPassword };
    const response = await db('user').insert(newUser);

    // Registra a ação de cadastro bem-sucedido
    logAction({
      name: name,
      email: email,
      acao: 'Cadastro de novo usuário com sucesso'
    });

    console.log("Novo usuário adicionado com sucesso.");
    return response;
  } catch (error) {
    // Em caso de erro, registra o erro
    logAction({
      name: name,
      email: email,
      acao: `Erro no cadastro: ${error.message}`
    });
    console.error("Erro ao adicionar novo usuário:", error);
    throw error;
  }
}

async function validateUser(email, password) {
  try {
    // Consulta o usuário pelo email no banco de dados
    console.log('here')
    const user = await db('user')
      .select('email', 'password')
      .where({ 'email': email })
      .first()
      .limit(1);
      console.log(user)
    // Se o usuário não existir, retorna false
    if (!user) {
      console.error("Usuário não encontrado para o email:", email);
      return false;
    }

    // Compara a senha fornecida com a senha armazenada no banco de dados
    const passwordMatch = await bcrypt.compare(password, user.password);

    // Retorna true se as senhas coincidirem, caso contrário, retorna false
    return passwordMatch;
  } catch (error) {
    // Em caso de erro, registra o erro
    console.error("Erro ao validar usuário:", error);
    return false;
  }
}



module.exports = { findUserByEmail, addUser, validateUser };
