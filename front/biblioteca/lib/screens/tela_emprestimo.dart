
import 'package:biblioteca/data/models/emprestimos_model.dart';
import 'package:biblioteca/data/models/usuario_model.dart';
import 'package:biblioteca/data/providers/usuario_provider.dart';
import 'package:biblioteca/tem_tabela/book_data.dart';
import 'package:biblioteca/tem_tabela/book_model.dart';
import 'package:flutter/material.dart';
import 'package:biblioteca/widgets/navegacao/bread_crumb.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PaginaEmprestimo extends StatefulWidget {
  const PaginaEmprestimo({super.key});

  @override
  State<PaginaEmprestimo> createState() => _PaginaEmprestimoState();
}

class _PaginaEmprestimoState extends State<PaginaEmprestimo> {
  late TextEditingController _searchController;
  late TextEditingController _searchControllerBooks;
  late List<Usuario> _filteredUsers;
  bool search = false;
  bool showSearchBooks = false;
  bool showBooks = false;
  bool showLivrosEmprestados = false;
  int selectOption = -1;
  Book? selectbook;
  late Usuario? selectUser;  // Inicializado como null
   // Lista de livros (precisa ser preenchida com dados reais)
 
  late String dataDevolucao;
  late String dataEmprestimo;

  late List<Usuario>users;
  
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchControllerBooks = TextEditingController();
    _filteredUsers = [];
    
     WidgetsBinding.instance.addPostFrameCallback((_) {
    Provider.of<UsuarioProvider>(context, listen: false).loadUsuarios().then((_) {
      setState(() {
        users = Provider.of<UsuarioProvider>(context, listen: false).users;
      });
    }).catchError((error) {
      
      print('Erro ao carregar usuários: $error');
    });
  });
  }
  @override
  void dispose() {
    _searchController.dispose();
    _searchControllerBooks.dispose();
    super.dispose();
  }

  void searchUsers() {
    final searchQuery = _searchController.text.toLowerCase();

    setState(() {
      search = true;
      _filteredUsers = users.where((usuario) {
        return usuario.nome.toLowerCase().contains(searchQuery) || usuario.login.contains(searchQuery);
      }).toList();
    });
  }

  void searchBooks() {
    showBooks = true;
    final searchQuery = _searchControllerBooks.text.toLowerCase();
    setState(() {
    selectbook = booksEmprestimo.firstWhere(
      (book) => book.codigo.toLowerCase().contains(searchQuery),
    );
  });
}
 void getDate(){
  DateTime now = DateTime.now();
  // Formata a data atual (data de empréstimo)
  dataEmprestimo = DateFormat('dd-MM-yyyy').format(now);
  // Calcula a data de devolução (7 dias depois)
  DateTime dataDevolucaoDate = now.add(const Duration(days: 7));
  dataDevolucao = DateFormat('dd-MM-yyyy').format(dataDevolucaoDate);
 }

String renovar(String dataString) {
  final formato = DateFormat('dd-MM-yyyy');
  final data = formato.parse(dataString);
  final novaData = data.add(const Duration(days: 7));
  return formato.format(novaData);
}
Future<void> msgConfirm(BuildContext context, String msg, EmprestimosModel livro){
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 6, left: 10, right: 10, bottom: 14),
          child: SizedBox(
            width: 800,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  width: double.infinity,
                  color: const Color.fromRGBO(38, 42, 79, 1),
                  child: Text('Confirmação De $msg', textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, color: Colors.white),),
                ),
                const SizedBox(height: 20,),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(0.10),
                      1: FlexColumnWidth(0.10),
                      2: FlexColumnWidth(0.20),
                      3: FlexColumnWidth(0.15),
                      4: FlexColumnWidth(0.15),
                    },
                    border: TableBorder.all(color: const Color.fromARGB(255, 213, 213, 213)),
                    children: [
                      TableRow(
                          decoration: const BoxDecoration(color: Color.fromARGB(255, 233, 235, 238)),
                          children: [
                             const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Codigo', textAlign: TextAlign.left,style:TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(7.0),
                              child: Text('ISBN', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(7.0),
                              child: Text('Nome', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(7.0),
                              child: Text('Devolução Prevista', textAlign: TextAlign.left, style:TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(7.0),
                              child: Text('Situação $msg', textAlign: TextAlign.left, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ]
                        ),
                        TableRow(
                          children: [
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(livro.codigo, textAlign: TextAlign.left,),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(livro.isbn, textAlign: TextAlign.left,),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(livro.nome, textAlign: TextAlign.left,),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(livro.dataDevolucao, textAlign: TextAlign.left),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('$msg Realizado!', textAlign: TextAlign.left,style:const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ]
                        )
                    ]
                ),
                
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.green[400],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Fecha o diálogo
                  },
                  child: const Text('Confirmar',style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          const BreadCrumb(breadcrumb: ['Início', 'Empréstimo'], icon: Icons.my_library_books_rounded),
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 35, right: 200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pesquisa De Aluno", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
                const SizedBox(height: 40),
                Row(
                  children: [
                    SizedBox(
                      width: 800,
                      height: 40,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          labelText: "Insira os dados do aluno",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          backgroundColor: const Color.fromRGBO(38, 42, 79, 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: searchUsers,
                      child: const Text("Pesquisar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                if (search)
                  if (_filteredUsers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Nenhum usuário encontrado', style: TextStyle(fontSize: 16)),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (selectUser == null)
                          SizedBox(
                            width: 1050,
                            child: Table(
                              border: TableBorder.all(color: const Color.fromARGB(255, 213, 213, 213)),
                              columnWidths: const {
                                0: FlexColumnWidth(0.50),
                                1: FlexColumnWidth(0.15),
                                2: FlexColumnWidth(0.15),
                                3: FlexColumnWidth(0.35),
                                4: FlexColumnWidth(0.15),
                                5: FlexColumnWidth(0.20),
                              },
                              children: [
                                const TableRow(
                                  decoration: BoxDecoration(color: Color.fromARGB(120, 255, 255, 255)),
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Nome', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Turma', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Turno', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Email', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Tipo Usuário', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    SizedBox(width: 5),
                                  ],
                                ),
                                for (int x = 0; x < _filteredUsers.length; x++)
                                  TableRow(
                                    decoration: const BoxDecoration(color: Color.fromARGB(120, 255, 255, 255)),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(_filteredUsers[x].nome, textAlign: TextAlign.left),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('${_filteredUsers[x].turma}', textAlign: TextAlign.left),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(_filteredUsers[x].turno.toString(), textAlign: TextAlign.left),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(_filteredUsers[x].email, textAlign: TextAlign.left),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(_filteredUsers[x].permissao.toString(), textAlign: TextAlign.left),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: const Color.fromRGBO(38, 42, 79, 1),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                          ),
                                          onPressed: () {
                                              showSearchBooks = true;
                                              setState(() {
                                                selectUser = _filteredUsers[x];
                                              });
                                          },
                                          child: const Text('Selecionar Leitor', style: TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.center),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        if (selectUser != null)
                          SizedBox(
                            width: 1050,
                            child: Column(
                              children: [
                                Table(
                                  border: TableBorder.all(color: const Color.fromARGB(255, 213, 213, 213)),
                                  columnWidths: const {
                                    0: FlexColumnWidth(0.50),
                                    1: FlexColumnWidth(0.15),
                                    2: FlexColumnWidth(0.15),
                                    3: FlexColumnWidth(0.35),
                                    4: FlexColumnWidth(0.15),
                                  },
                                  children: [
                                    const TableRow(
                                      decoration: BoxDecoration(color: Color.fromARGB(120, 255, 255, 255)),
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Nome', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Turma', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Turno', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Email', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Tipo Usuário', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      decoration: const BoxDecoration(color: Color.fromARGB(120, 255, 255, 255)),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(selectUser!.nome, textAlign: TextAlign.left),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(selectUser!.turma.toString(), textAlign: TextAlign.left),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(selectUser!.turno.toString(), textAlign: TextAlign.left),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(selectUser!.email, textAlign: TextAlign.left),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(selectUser!.permissao.toString(), textAlign: TextAlign.left),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                
                                if(selectUser != null && selectUser!.livrosEmprestados.isNotEmpty)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color.fromARGB(255, 213, 213, 213)
                                      ),
                                      color:  const Color.fromARGB(255, 233, 235, 238),
                                    ),
                                    child: Text(
                                      "Livros Emprestados",
                                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                if(selectUser != null && selectUser!.livrosEmprestados.isNotEmpty)
                                  Table(
                                    columnWidths: const {
                                      0: FlexColumnWidth(0.10),
                                              1: FlexColumnWidth(0.10),
                                              2: FlexColumnWidth(0.20),
                                              3: FlexColumnWidth(0.15),
                                              4: FlexColumnWidth(0.15),
                                              5: FlexColumnWidth(0.12),
                                    },
                                    border: TableBorder.all(color: const Color.fromARGB(255, 213, 213, 213)),
                                    children: [
                                      const TableRow(
                                          decoration: BoxDecoration(color: Color.fromARGB(255, 233, 235, 238)),
                                          children: [
                                             Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('Codigo', textAlign: TextAlign.left,style:TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(7.0),
                                              child: Text('ISBN', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(7.0),
                                              child: Text('Nome', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(7.0),
                                              child: Text('Data de Empréstimo', textAlign: TextAlign.left, style:TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(7.0),
                                              child: Text('Data de Devolução', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            SizedBox.shrink()
                                          ]
                                        ),
                                      for (int x = 0; x < selectUser!.livrosEmprestados.length; x++)
                                        TableRow(
                                          decoration: const BoxDecoration(color: Color.fromRGBO(233, 235, 238, 75)),
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(7.0),
                                              child: Text(selectUser!.livrosEmprestados[x].codigo, textAlign: TextAlign.left),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(7.0),
                                              child: Text(selectUser!.livrosEmprestados[x].isbn, textAlign: TextAlign.left),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(7.0),
                                              child: Text(selectUser!.livrosEmprestados[x].nome, textAlign: TextAlign.left),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(7.0),
                                              child: Text(selectUser!.livrosEmprestados[x].dataEmprestimo, textAlign: TextAlign.left),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(7.0),
                                              child: Text(selectUser!.livrosEmprestados[x].dataDevolucao, textAlign: TextAlign.left),
                                            ),
                                            Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: TextButton(
                                            style: TextButton.styleFrom(
                                              backgroundColor: Colors.orange[400],
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                selectUser!.livrosEmprestados[x].dataDevolucao = renovar(selectUser!.livrosEmprestados[x].dataDevolucao);
                                              });
                                              msgConfirm(context, 'Renovação', selectUser!.livrosEmprestados[x]);
                                            },
                                            child: const Text('Renovar', style: TextStyle(color:  Colors.white, fontSize: 12), textAlign: TextAlign.center),
                                          ),
                                        ),
                                          ]
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          if (showSearchBooks)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 50),
                                Text("Pesquisar Exemplar", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
                                const SizedBox(height: 40),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 800,
                                      height: 40,
                                      child: TextField(
                                        controller: _searchControllerBooks,
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(Icons.search),
                                          labelText: "Insira os dados do livro",
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 30),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                          backgroundColor: const Color.fromRGBO(38, 42, 79, 1),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                      onPressed: searchBooks,
                                      child: const Text("Pesquisar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 40),
                                if(showBooks)
                                  if (selectbook == null)
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Nenhum livro encontrado', style: TextStyle(fontSize: 16)),
                                    )
                                  else
                                    Column(
                                      children: [
                                        SizedBox(
                                          width: 1050,
                                          child: Table(
                                            border: TableBorder.all(color: const Color.fromARGB(255, 213, 213, 213)),
                                            columnWidths: const {
                                              0: FlexColumnWidth(0.10),
                                              1: FlexColumnWidth(0.10),
                                              2: FlexColumnWidth(0.20),
                                              3: FlexColumnWidth(0.15),
                                              4: FlexColumnWidth(0.15),
                                              5: FlexColumnWidth(0.12),
                                            },
                                            children: [
                                              const TableRow(
                                                decoration: BoxDecoration(color: Color.fromARGB(255, 233, 235, 238)),
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text('Codigo', textAlign: TextAlign.left,style:TextStyle(fontWeight: FontWeight.bold)),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text('ISBN', textAlign: TextAlign.left, style:TextStyle(fontWeight: FontWeight.bold)),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text('Nome', textAlign: TextAlign.left, style:TextStyle(fontWeight: FontWeight.bold)),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text('Editora', textAlign: TextAlign.left, style:TextStyle(fontWeight: FontWeight.bold)),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text('Data de Publicação', textAlign: TextAlign.left, style:TextStyle(fontWeight: FontWeight.bold)),
                                                  ),
                                                  SizedBox.shrink()
                                                ],
                                              ),
                                                TableRow(
                                                  decoration: const BoxDecoration(color: Color.fromRGBO(233, 235, 238, 75)),
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Text(selectbook!.codigo, textAlign: TextAlign.left),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Text(selectbook!.isbn, textAlign: TextAlign.left),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Text(selectbook!.nome, textAlign: TextAlign.left),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Text(selectbook!.editora, textAlign: TextAlign.left),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Text(selectbook!.dataPublicacao, textAlign: TextAlign.left),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: TextButton(
                                                        style: TextButton.styleFrom(
                                                          backgroundColor: Colors.green[400],
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                                        ),
                                                        onPressed: () {
                                                          showLivrosEmprestados = true;
                                                          getDate();
                                                          setState(() {
                                                            users[users.indexOf(selectUser!)].livrosEmprestados.add(EmprestimosModel(selectbook!.codigo, selectbook!.isbn,selectbook!.nome, dataEmprestimo, dataDevolucao));
                                                          });
                                                          msgConfirm(context, 'Empréstimo', selectUser!.livrosEmprestados.last);
                                                        },
                                                        child: const Text('Emprestar', style: TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.center),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                const SizedBox(height: 150,)
                              ],
                            ),
                      ],
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

