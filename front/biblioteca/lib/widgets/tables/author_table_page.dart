import 'package:biblioteca/data/models/autor_model.dart';
import 'package:biblioteca/data/providers/autor_provider.dart';
import 'package:biblioteca/widgets/tables/autores_obras_table_page.dart';
import 'package:biblioteca/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:biblioteca/widgets/navegacao/bread_crumb.dart';
import 'package:provider/provider.dart';

class AuthorTablePage extends StatefulWidget {
  const AuthorTablePage({super.key});

  @override
  AuthorTablePageState createState() => AuthorTablePageState();
}

class AuthorTablePageState extends State<AuthorTablePage> {
  int rowsPerPage = 10; // Quantidade de linhas por página
  final List<int> rowsPerPageOptions = [5, 10, 15, 20];
  int currentPage = 1; // Página atual
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  // Ordenação
  String _sortColumn =
      'nome'; // 'nome', 'anoNascimento', 'nacionalidade', 'sexo'
  bool _isAscending = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AutorProvider>(context, listen: false).loadAutores();
    });
    super.initState();
  }

  _delete(author) async {
    await Provider.of<AutorProvider>(context, listen: false)
        .deleteAutor(author);
  }

  @override
  Widget build(BuildContext context) {
    AutorProvider autorProvider = Provider.of<AutorProvider>(context);
    List<Autor> autores = context.watch<AutorProvider>().autores;

    if (autorProvider.isloading) {
      return const Center(child: CircularProgressIndicator());
    } else if (autorProvider.hasErrors) {
      return Text(autorProvider.error ?? 'Erro desconhecido');
    } else {
      return tableAutor(context, autores);
    }
  }

  Material tableAutor(BuildContext context, List<Autor> autores) {
    List<Autor> authors = autores;

    // Filtro de busca
    if (_searchText.isNotEmpty) {
      authors = authors
          .where((a) =>
              a.nome.toLowerCase().contains(_searchText) ||
              (a.nacionalidade?.toLowerCase().contains(_searchText) ?? false) ||
              (a.sexo?.toLowerCase().contains(_searchText) ?? false))
          .toList();
    }

    // Ordenação
    authors.sort((a, b) {
      int cmp;
      switch (_sortColumn) {
        case 'nome':
          cmp = a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
          break;
        case 'nacionalidade':
          cmp = (a.nacionalidade ?? '')
              .toLowerCase()
              .compareTo((b.nacionalidade ?? '').toLowerCase());
          break;
        case 'sexo':
          cmp = (a.sexo ?? '')
              .toLowerCase()
              .compareTo((b.sexo ?? '').toLowerCase());
          break;
        default:
          cmp = 0;
      }
      return _isAscending ? cmp : -cmp;
    });

    int totalPages = (authors.length / rowsPerPage).ceil();

    // Calcula o índice inicial e final dos autores exibidos
    int startIndex = (currentPage - 1) * rowsPerPage;
    int endIndex = (startIndex + rowsPerPage) < authors.length
        ? (startIndex + rowsPerPage)
        : authors.length;

    // Seleciona os autores que serão exibidos na página atual
    List<Autor> paginatedAuthors = authors.sublist(startIndex, endIndex);

    // Lógica para definir os botões de página (máximo 9 botões)
    int startPage = currentPage - 4 < 1 ? 1 : currentPage - 4;
    int endPage = startPage + 8 > totalPages ? totalPages : startPage + 8;
    if (endPage - startPage < 8 && startPage > 1) {
      startPage = endPage - 8 < 1 ? 1 : endPage - 8;
    }

    return Material(
      child: Column(
        children: [
          // Barra de navegação
          const BreadCrumb(
              breadcrumb: ["Início", "Autores"],
              icon: Icons.menu_book_outlined),

          // Corpo da página
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 40),
            child: Column(
              // Botão novo autor
              children: [
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.novoAutor);
                      },
                      label: const Text(
                        'Novo Autor',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.green.shade800),
                        foregroundColor:
                            const WidgetStatePropertyAll(Colors.white),
                        padding: WidgetStateProperty.all<EdgeInsets>(
                          const EdgeInsets.all(15.0),
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(
                  height: 20.0,
                ),

                // Registros por página e campo de Pesquisa
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Registros por página
                      Row(
                        children: [
                          const Text('Exibir'),
                          const SizedBox(width: 8),
                          DropdownButton<int>(
                            value: rowsPerPage,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  rowsPerPage = value;
                                  currentPage = 1;
                                });
                              }
                            },
                            items: rowsPerPageOptions.map((int value) {
                              return DropdownMenuItem<int>(
                                  value: value, child: Text(value.toString()));
                            }).toList(),
                          ),
                          const SizedBox(width: 8),
                          const Text('registros por página'),
                        ],
                      ),
                      // Pesquisar
                      SizedBox(
                        width: 300,
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            labelText: 'Pesquisar',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchText = value.toLowerCase();
                              currentPage = 1;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tabela de autores
                Table(
                  border: TableBorder.all(
                      color: const Color.fromARGB(215, 200, 200, 200)),
                  columnWidths: const {
                    0: FlexColumnWidth(0.40),
                    1: FlexColumnWidth(0.40),
                    2: FlexColumnWidth(0.40),
                    3: FlexColumnWidth(0.40),
                    4: IntrinsicColumnWidth()
                  },
                  children: [
                    // Cabeçalho da tabela com ordenação
                    TableRow(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 38, 42, 79),
                      ),
                      children: [
                        // Nome
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if (_sortColumn == 'nome') {
                                  _isAscending = !_isAscending;
                                } else {
                                  _sortColumn = 'nome';
                                  _isAscending = true;
                                }
                              });
                            },
                            child: Row(
                              children: [
                                const Text(
                                  'Nome',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontSize: 15),
                                ),
                                Icon(
                                  _sortColumn == 'nome'
                                      ? (_isAscending
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward)
                                      : Icons.unfold_more,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Nacionalidade
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if (_sortColumn == 'nacionalidade') {
                                  _isAscending = !_isAscending;
                                } else {
                                  _sortColumn = 'nacionalidade';
                                  _isAscending = true;
                                }
                              });
                            },
                            child: Row(
                              children: [
                                const Text(
                                  'Nacionalidade',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontSize: 15),
                                ),
                                Icon(
                                  _sortColumn == 'nacionalidade'
                                      ? (_isAscending
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward)
                                      : Icons.unfold_more,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Sexo
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if (_sortColumn == 'sexo') {
                                  _isAscending = !_isAscending;
                                } else {
                                  _sortColumn = 'sexo';
                                  _isAscending = true;
                                }
                              });
                            },
                            child: Row(
                              children: [
                                const Text(
                                  'Sexo',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontSize: 15),
                                ),
                                Icon(
                                  _sortColumn == 'sexo'
                                      ? (_isAscending
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward)
                                      : Icons.unfold_more,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Opções
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Opções',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontSize: 15)),
                        ),
                      ],
                    ),

                    // Linhas da tabela
                    for (int x = 0; x < paginatedAuthors.length; x++)
                      TableRow(
                        decoration: BoxDecoration(
                          color: x % 2 == 0
                              ? const Color.fromRGBO(233, 235, 238, 75)
                              : const Color.fromRGBO(255, 255, 255, 1),
                        ),
                        children: [
                          Align(
                            alignment: Alignment
                                .centerLeft, // Alinha o texto à esquerda
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(paginatedAuthors[x].nome,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize:
                                          14.5)), // Alinhamento horizontal
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(paginatedAuthors[x].nacionalidade,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14.5)),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(paginatedAuthors[x].sexo,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14.5)),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (dialogContext) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Excluir Usuário'),
                                              content: const Text(
                                                  'Tem certeza que deseja excluir este Autor?'),
                                              actions: [
                                                ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          dialogContext);
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color.fromARGB(
                                                              255,
                                                              128,
                                                              128,
                                                              128),
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 5),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                    ),
                                                    child:
                                                        const Text('Cancelar')),
                                                //Aqui é o botão excluir inferno
                                                ElevatedButton(
                                                    onPressed: () {
                                                      _delete(
                                                          paginatedAuthors[x]);
                                                      Navigator.pop(
                                                          dialogContext);
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 5),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                    ),
                                                    child:
                                                        const Text('Confirmar'))
                                              ],
                                            );
                                          });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.delete, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text('Excluir',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, AppRoutes.editarAutor,
                                          arguments: paginatedAuthors[x]);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 38, 42, 79),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.edit, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text('Editar',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ObrasPage(
                                                autor: paginatedAuthors[x])),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 128, 128, 128),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.library_books_rounded,
                                            color: Colors.white),
                                        SizedBox(width: 4),
                                        Text('Obras',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // Barra de navegação de páginas
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: currentPage > 1
                            ? () {
                                setState(() {
                                  currentPage--;
                                });
                              }
                            : null,
                      ),
                      for (int i = startPage; i <= endPage; i++)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              currentPage = i;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: i == currentPage
                                  ? Color.fromARGB(255, 38, 42, 79)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4.0),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Text(
                              i.toString(),
                              style: TextStyle(
                                color: i == currentPage
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: currentPage < totalPages
                            ? () {
                                setState(() {
                                  currentPage++;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
