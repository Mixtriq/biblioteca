package banco

import (
	//"log"
	"biblioteca/modelos"
	"context"
	"crypto/sha256"
	"fmt"

	pgx "github.com/jackc/pgx/v5"
)

type ErroBancoUsuario int

func CriptografarSenha(senha string) string {
	hash := sha256.New()
	hash.Write([]byte(senha))
	return fmt.Sprintf("%x", hash.Sum(nil))
}

func CriarUsuario(novoUsuario modelos.Usuario) ErroBancoUsuario {
	conexao := PegarConexao()

	if EmailDuplicado(novoUsuario.Email) {
		return ErroEmailDuplicado
	}

	if LoginDuplicado(novoUsuario.Login) {
		return ErroLoginDuplicado
	}

	if len(novoUsuario.Cpf) > 0 && CpfDuplicado(novoUsuario.Cpf) {
		return ErroCpfDuplicado
	}

	var cpf interface{} = novoUsuario.Cpf
	if len(cpf.(string)) == 0 {
		cpf = nil
	}

	var telefone interface{} = novoUsuario.Telefone
	if len(telefone.(string)) == 0 {
		telefone = nil
	}

	var data_nascimento interface{} = novoUsuario.DataDeNascimento
	if len(data_nascimento.(string)) == 0 {
		data_nascimento = nil
	}

	senhaCriptogrfada := CriptografarSenha(novoUsuario.Senha)
	_, erroQuery := conexao.Exec(
		context.Background(),
		"insert into usuario(login,cpf, nome, email, telefone, data_nascimento, data_criacao, senha, permissoes) values ($1, $2, $3, $4, $5, $6, CURRENT_DATE, $7, $8)",
		novoUsuario.Login,
		cpf,
		novoUsuario.Nome,
		novoUsuario.Email,
		telefone,
		data_nascimento,
		senhaCriptogrfada,
		novoUsuario.Permissao,
	)

	if erroQuery != nil {
		fmt.Println(erroQuery)
		panic("Um erro imprevisto acontesceu no cadastro do usuário. Provavelmente é um bug")
	}

	return ErroNenhum
}

func AtualizarUsuario(usuarioComDadosAntigos, usuarioAtualizado modelos.Usuario) ErroBancoUsuario {

	fmt.Println(usuarioAtualizado)

	if usuarioComDadosAntigos.Login != usuarioAtualizado.Login && LoginDuplicado(usuarioAtualizado.Login) {
		return ErroLoginDuplicado
	}

	if len(usuarioAtualizado.Cpf) > 0 && (usuarioComDadosAntigos.Cpf != usuarioAtualizado.Cpf && CpfDuplicado(usuarioAtualizado.Cpf)) {
		return ErroCpfDuplicado
	}

	if usuarioComDadosAntigos.Email != usuarioAtualizado.Email && CpfDuplicado(usuarioAtualizado.Email) {
		return ErroEmailDuplicado
	}

	if len(usuarioAtualizado.Cpf) > 0 && CpfDuplicado(usuarioAtualizado.Cpf) {
		return ErroCpfDuplicado
	}

	var cpf interface{} = usuarioAtualizado.Cpf
	if len(cpf.(string)) == 0 {
		cpf = nil
	}

	var telefone interface{} = usuarioAtualizado.Telefone
	if len(telefone.(string)) == 0 {
		telefone = nil
	}

	var data_nascimento interface{} = usuarioAtualizado.DataDeNascimento
	if len(data_nascimento.(string)) == 0 {
		data_nascimento = nil
	}

	conexao := PegarConexao()
	textoQuery := "update usuario set login = $1, cpf = $2, nome = $3, email = $4, telefone = $5, data_nascimento = $6, data_atualizacao = CURRENT_DATE, permissoes = $7, ativo = $8 where id_usuario = $9"
	if _, erroQuery := conexao.Query(
		context.Background(),
		textoQuery,
		usuarioAtualizado.Login,
		cpf,
		usuarioAtualizado.Nome,
		usuarioAtualizado.Email,
		telefone,
		data_nascimento,
		usuarioAtualizado.Permissao,
		usuarioAtualizado.Ativo,
		usuarioAtualizado.IdDoUsuario,
	); erroQuery != nil {
		panic("Um erro desconhecido acontesceu na atualização do usuário")
	}

	if usuarioAtualizado.Senha != "" {
		senhaCriptogrfada := CriptografarSenha(usuarioAtualizado.Senha)
		textoQuery := "update usuario set senha = $1 where id_usuario = $2"
		if _, erroQuery := conexao.Query(context.Background(), textoQuery, senhaCriptogrfada, usuarioAtualizado.IdDoUsuario); erroQuery != nil {
			panic("Um erro desconhecido acontesceu na atualização do usuário")
		}
	}

	return ErroNenhum
}

func ExcluirUsuario(idDoUsuario int) ErroBancoUsuario {
	usuario, achou := PegarUsuarioPeloId(idDoUsuario)
	if !achou {
		fmt.Println("erro")
		return ErroUsuarioInexistente
	}
	fmt.Println(usuario)
	usuarioCopia := usuario
	usuario.Ativo = false
	return AtualizarUsuario(usuarioCopia, usuario)
}

func PesquisarUsuario(busca string) []modelos.Usuario {
	conexao := PegarConexao()
	busca = "%" + busca + "%" // isso está sujeitio a sql injection por favor olhar depois
	textoQuery := "select id_usuario, login, cpf, nome, email, telefone,  permissoes, to_char(data_nascimento, 'yyyy-mm-dd'), ativo from usuario where login like $1 or nome like $1 or email like $1"
	linhas, erro := conexao.Query(context.Background(), textoQuery, busca)
	if erro != nil {
		return []modelos.Usuario{}
	}
	var usuarioTemporario modelos.Usuario
	usuariosEncontrados := make([]modelos.Usuario, 0)
	var cpfTemporario interface{}
	var telefoneTemporario interface{}
	var dataDeNascimentoTemporaria interface{}
	_, erro = pgx.ForEachRow(linhas, []any{&usuarioTemporario.IdDoUsuario, &usuarioTemporario.Login, cpfTemporario, &usuarioTemporario.Nome, &usuarioTemporario.Email, telefoneTemporario, &usuarioTemporario.Permissao, dataDeNascimentoTemporaria, &usuarioTemporario.Ativo}, func() error {
		//fmt.Println(usuarioTemporario)
		//fmt.Println(usuariosEncontrados)
		if v, ok := cpfTemporario.(string); ok {
			usuarioTemporario.Cpf = v
		}
		if v, ok := telefoneTemporario.(string); ok {
			usuarioTemporario.Telefone = v
		}
		if v, ok := dataDeNascimentoTemporaria.(string); ok {
			usuarioTemporario.DataDeNascimento = v
		}

		usuariosEncontrados = append(usuariosEncontrados, usuarioTemporario)
		return nil
	})
	if erro != nil {
		fmt.Println(erro)
		return []modelos.Usuario{}
	}
	fmt.Println(usuariosEncontrados)
	return usuariosEncontrados
}

func PesquisarUsuarioPeloLogin(login string) (modelos.Usuario, bool) {
	conexao := PegarConexao()
	var usuario modelos.Usuario
	textoQuery := "select id_usuario, login, cpf, nome, email, telefone, to_char(data_nascimento, 'yyyy-mm-dd'), permissoes, ativo from usuario where login = $1"
	var cpfTemporario interface{}
	var telefoneTemporario interface{}
	var dataDeNascimentoTemporaria interface{}
	if erro := conexao.QueryRow(context.Background(), textoQuery, login).Scan(
		&usuario.IdDoUsuario,
		&usuario.Login,
		cpfTemporario,
		&usuario.Nome,
		&usuario.Email,
		telefoneTemporario,
		dataDeNascimentoTemporaria,
		&usuario.Permissao,
		&usuario.Ativo); erro == nil {
		if v, ok := cpfTemporario.(string); ok {
			usuario.Cpf = v
		}
		if v, ok := telefoneTemporario.(string); ok {
			usuario.Telefone = v
		}
		if v, ok := dataDeNascimentoTemporaria.(string); ok {
			usuario.DataDeNascimento = v
		}

		return usuario, false
	} else {
		return usuario, true
	}
}

func PegarUsuarioPeloId(id int) (modelos.Usuario, bool) {
	conexao := PegarConexao()
	var usuario modelos.Usuario
	var cpfTemporario interface{}
	var telefoneTemporario interface{}
	var dataDeNascimentoTemporaria interface{}
	textoQuery := "select id_usuario, login, cpf, nome, email, telefone, to_char(data_nascimento, 'yyyy-mm-dd'), permissoes, ativo from usuario where id_usuario = $1"
	if erro := conexao.QueryRow(context.Background(), textoQuery, id).Scan(
		&usuario.IdDoUsuario,
		&usuario.Login,
		cpfTemporario,
		&usuario.Nome,
		&usuario.Email,
		telefoneTemporario,
		dataDeNascimentoTemporaria,
		&usuario.Permissao,
		&usuario.Ativo); erro == nil {
		if v, ok := cpfTemporario.(string); ok {
			usuario.Cpf = v
		}
		if v, ok := telefoneTemporario.(string); ok {
			usuario.Telefone = v
		}
		if v, ok := dataDeNascimentoTemporaria.(string); ok {
			usuario.DataDeNascimento = v
		}
		return usuario, true
	} else {
		return usuario, false
	}
}

func PegarPermissao(loginDoUsuario string) uint64 {
	conexao := PegarConexao()
	var permissao uint64
	if conexao.QueryRow(context.Background(), "select permissoes from usuario where login = $1", loginDoUsuario).Scan(&permissao) == nil {
		return permissao
	} else {
		return 0
	}
}

func PegarIdUsuario(login string) int {
	conexao := PegarConexao()
	var id int
	if conexao.QueryRow(context.Background(), "select id_usuario from usuario where login = $1", login).Scan(&id) == nil {
		return id
	} else {
		return 0
	}
}

func CpfDuplicado(cpf string) bool {
	conexao := PegarConexao()
	qtdCpfs := 0
	if conexao.QueryRow(context.Background(), "select count(cpf) from usuario u where cpf = $1", cpf).Scan(&qtdCpfs) == nil {
		return qtdCpfs > 0
	} else {
		panic("Erro ao procurar por cpf duplicado. Provavelmente é um bug")
	}
}

func EmailDuplicado(email string) bool {
	conexao := PegarConexao()
	qtdEmail := 0
	if conexao.QueryRow(context.Background(), "select count(email) from usuario u where email = $1", email).Scan(&qtdEmail) == nil {
		return qtdEmail > 0
	} else {
		panic("Erro ao procurar por email duplicado. Provavelmente é um bug")

	}
}

func LoginDuplicado(login string) bool {
	conexao := PegarConexao()
	qtdLogin := 0
	if conexao.QueryRow(context.Background(), "select count(login) from usuario u where login = $1", login).Scan(&qtdLogin) == nil {
		return qtdLogin > 0
	} else {
		panic("Erro ao procurar por login duplicado. Provavelmente é um bug")
	}
}
