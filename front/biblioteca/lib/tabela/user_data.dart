import 'package:biblioteca/tabela/user_model.dart';

List<User> users = List.generate(
  100,
  (index) => User(
    nome: 'Usuário $index',
    matricula: '00$index',
    turma: index % 2 == 0 ? 'N/A' : '2º Ano',
    turno: index % 2 == 0 ? 'N/A' : 'Matutino',
    tipoUsuario: index % 2 == 0 ? 'Docente' : 'Discente',
  ),
);
