defmodule Minesweeper do
  # PRIMEIRA PARTE - FUNÇÕES PARA MANIPULAR OS TABULEIROS DO JOGO (MATRIZES)

  # A ideia das próximas funções é permitir que a gente acesse uma lista usando um indice,
  # como se fosse um vetor

  # get_arr/2 (get array):  recebe uma lista (vetor) e uma posicao (p) e devolve o elemento
  # na posição p do vetor. O vetor começa na posição 0 (zero). Não é necessário tratar erros.

  def get_arr([h | _t], 0), do: h
  def get_arr([_h | t], n), do: get_arr(t, n - 1)

  # update_arr/3 (update array): recebe uma lista(vetor), uma posição (p) e um novo valor (v)e devolve um
  # novo vetor com o valor v na posição p. O vetor começa na posição 0 (zero)

  def update_arr([_h | t], 0, v), do: [v | t]
  def update_arr([h | t], n, v), do: [h | update_arr(t, n - 1, v)]

  # O tabuleiro do jogo é representado como uma matriz. Uma matriz, nada mais é do que um vetor de vetores.
  # Dessa forma, usando as operações anteriores, podemos criar funções para acessar os tabuleiros, como
  # se  fossem matrizes:

  # get_pos/3 (get position): recebe um tabuleiro (matriz), uma linha (l) e uma coluna (c) (não precisa validar).
  # Devolve o elemento na posicao tabuleiro[l,c]. Usar get_arr/2 na implementação

  def get_pos(tab, l, c), do: get_arr(get_arr(tab, l), c)

  # update_pos/4 (update position): recebe um tabuleiro, uma linha, uma coluna e um novo valor. Devolve
  # o tabuleiro modificado com o novo valor na posiçao linha x coluna. Usar update_arr/3 e get_arr/2 na implementação

  def update_pos(tab, l, c, v), do: update_arr(tab, l, update_arr(get_arr(tab, l), c, v))

  # SEGUNDA PARTE: LÓGICA DO JOGO

  # -- is_mine/3: recebe um tabuleiro com o mapeamento das minas, uma linha, uma coluna. Devolve true caso a posição contenha
  # uma mina e false caso contrário. Usar get_pos/3 na implementação
  #
  # Exemplo de tabuleiro de minas:

  def get_fake_mine_board() do
    [
      [false, false, false, false, false, false, false, false, false],
      [false, false, false, false, false, false, false, false, false],
      [false, false, false, false, false, false, false, false, false],
      [false, false, false, false, false, false, false, false, false],
      [false, false, false, true, true, true, false, false, false],
      [false, false, false, false, false, true, false, false, false],
      [false, false, false, false, true, false, false, false, false],
      [false, false, false, true, false, false, false, false, false],
      [false, false, false, false, false, false, false, false, false]
    ]
  end

  #
  # esse tabuleiro possuí minas nas posições 4x4 e 5x5

  def is_mine(tab, l, c), do: get_pos(tab, l, c)

  # is_valid_pos/3 recebe o tamanho do tabuleiro (ex, em um tabuleiro 9x9, o tamanho é 9),
  # uma linha e uma coluna, e diz se essa posição é válida no tabuleiro. Por exemplo, em um tabuleiro
  # de tamanho 9, as posições 1x3,0x8 e 8x8 são exemplos de posições válidas. Exemplos de posições
  # inválidas seriam 9x0, 10x10 e -1x8

  def is_valid_pos(tamanho, l, c), do: l < tamanho && c < tamanho && l >= 0 && c >= 0

  # valid_moves/3: Dado o tamanho do tabuleiro e uma posição atual (linha e coluna), retorna uma lista
  # com todas as posições adjacentes à posição atual
  # Exemplo: Dada a posição linha 3, coluna 3, as posições adjacentes são: [{2,2},{2,3},{2,4},{3,2},{3,4},{4,2},{4,3},{4,4}]
  #   ...   ...      ...    ...   ...
  #   ...  (2,2)    (2,3)  (2,4)  ...
  #   ...  (3,2)    (3,3)  (3,4)  ...
  #   ...  (4,2)    (4,3)  (4,4)  ...
  #   ...   ...      ...    ...   ...

  #  Dada a posição (0,0) que é um canto, as posições adjacentes são: [(0,1),(1,0),(1,1)]

  #  (0,0)  (0,1) ...
  #  (1,0)  (1,1) ...
  #   ...    ...  ..
  # Uma maneira de resolver seria gerar todas as 8 posições adjacentes e depois filtrar as válidas usando is_valid_pos
  def valid_moves(tam, l, c), do: get_window(l, c) |> filter_invalid(tam, l, c)

  def get_window(l, c),
    do: line_positions(l - 1, c) ++ line_positions(l, c) ++ line_positions(l + 1, c)

  def line_positions(l, c), do: [{l, c - 1}, {l, c}, {l, c + 1}]

  def filter_invalid(window, tam, l, c) do
    Enum.filter(window, fn {fl, fc} ->
      is_valid_pos(tam, fl, fc) && !(fl == l && fc == c)
    end)
  end

  # conta_minas_adj/3: recebe um tabuleiro com o mapeamento das minas e uma  uma posicao  (linha e coluna), e conta quantas minas
  # existem nas posições adjacentes

  def conta_minas_adj(tab, l, c) do
    counter = fn {fl, fc}, acc ->
      if get_pos(tab, fl, fc) do
        acc + 1
      else
        acc
      end
    end

    Enum.reduce(valid_moves(length(tab), l, c), 0, counter)
  end

  # abre_jogada/4: é a função principal do jogo!!
  # recebe uma posição a ser aberta (linha e coluna), o mapa de minas e o tabuleiro do jogo. Devolve como
  # resposta o tabuleiro do jogo modificado com essa jogada.
  # Essa função é recursiva, pois no caso da entrada ser uma posição sem minas adjacentes, o algoritmo deve
  # seguir abrindo todas as posições adjacentes até que se encontre posições adjacentes à minas.
  # Vamos analisar os casos:
  # - Se a posição a ser aberta é uma mina, o tabuleiro não é modificado e encerra
  # - Se a posição a ser aberta já foi aberta, o tabuleiro não é modificado e encerra
  # - Se a posição a ser aberta é adjacente a uma ou mais minas, devolver o tabuleiro modificado com o número de
  # minas adjacentes na posição aberta
  # - Se a posição a ser aberta não possui minas adjacentes, abrimos ela com zero (0) e recursivamente abrimos
  # as outras posições adjacentes a ela

  def abre_jogada(l, c, minas, tab) do
    if is_mine(minas, l, c) || get_pos(tab, l, c) != "-" do
      tab
    else
      abre_posicao(tab, minas, l, c)
    end
  end

  # abre_posicao/4, que recebe um tabueiro de jogos, o mapa de minas, uma linha e uma coluna
  # Essa função verifica:
  # - Se a posição {l,c} já está aberta (contém um número), então essa posição não deve ser modificada
  # - Se a posição {l,c} contém uma mina no mapa de minas, então marcar  com "*" no tabuleiro
  # - Se a posição {l,c} está fechada (contém "-"), escrever o número de minas adjascentes a esssa posição no tabuleiro (usar conta_minas)

  def abre_posicao(tab, minas, l, c) do
    if get_pos(tab, l, c) != "-" do
      tab
    else
      if is_mine(minas, l, c) do
        update_pos(tab, l, c, "*")
      else
        num_minas = conta_minas_adj(minas, l, c)

        cond do
          num_minas == 0 ->
            Enum.reduce(valid_moves(length(tab), l, c), tab, fn {fl, fc}, acc ->
              update_pos(acc, l, c, num_minas) |> abre_posicao(minas, fl, fc)
            end)

          true ->
            update_pos(tab, l, c, num_minas)
        end
      end
    end
  end

  # abre_tabuleiro/2: recebe o mapa de Minas e o tabuleiro do jogo, e abre todo o tabuleiro do jogo, mostrando
  # onde estão as minas e os números nas posições adjecentes às minas.Essa função é usada para mostrar
  # todo o tabuleiro no caso de vitória ou derrota. Para implementar esta função, usar a função abre_posicao/4

  def abre_tabuleiro(minas, tab) do
    abre_tabuleiro(minas, tab, 0, 0)
  end

  def abre_tabuleiro(minas, tab, l, c) do
    cond do
      l == length(tab) -> tab
      c == length(tab) -> abre_tabuleiro(minas, tab, l + 1, 0)
      true -> abre_tabuleiro(minas, abre_posicao(tab, minas, l, c), l, c + 1)
    end
  end

  def test_abre_tabuleiro() do
    abre_tabuleiro(get_fake_mine_board(), gera_tabuleiro(9)) |> board_to_string()
  end

  # board_to_string/1: -- Recebe o tabuleiro do jogo e devolve uma string que é a representação visual desse tabuleiro.
  # Essa função é aplicada no tabuleiro antes de fazer o print dele na tela. Usar a sua imaginação para fazer um
  # tabuleiro legal. Olhar os exemplos no .pdf com a especificação do trabalho. Não esquecer de usar \n para quebra de linhas.
  # Você pode quebrar essa função em mais de uma: print_header, print_linhas, etc...

  def board_to_string(tab, 0, cols) do
    IO.puts("    " <> Enum.join(cols, "   "))
    IO.puts("0 | " <> Enum.join(get_arr(tab, 0), " | ") <> " |")
  end

  def board_to_string(tab, n, cols) do
    board_to_string(tab, n - 1, [n - 1 | cols])
    IO.puts("#{n} | " <> Enum.join(get_arr(tab, n), " | ") <> " |")
  end

  def board_to_string(tab) do
    IO.puts "\e[2J"
    n = length(tab)
    board_to_string(tab, n - 1, [n - 1])
  end

  def test_board_to_string(size) do
    board_to_string(gera_tabuleiro(size))
  end

  # gera_lista/2: recebe um inteiro n, um valor v, e gera uma lista contendo n vezes o valor v

  def gera_lista(0, _v), do: []
  def gera_lista(n, v), do: [v | gera_lista(n - 1, v)]

  # -- gera_tabuleiro/1: recebe o tamanho do tabuleiro de jogo e gera um tabuleiro  novo, todo fechado (todas as posições
  # contém "-"). Usar gera_lista

  def gera_tabuleiro(n), do: gera_lista(n, gera_lista(n, "-"))

  # -- gera_mapa_de_minas/1: recebe o tamanho do tabuleiro e gera um mapa de minas zero, onde todas as posições contém false

  def gera_mapa_de_minas(n), do: gera_lista(n, gera_lista(n, false))

  # conta_fechadas/1: recebe um tabueleiro de jogo e conta quantas posições fechadas existem no tabuleiro (posições com "-")

  def conta_fechadas([]), do: 0

  def conta_fechadas([h | t]) do
    conta_linha(h, "-", 0) + conta_fechadas(t)
  end

  def conta_linha([], _v, acc), do: acc

  def conta_linha([h | t], v, acc) do
    cond do
      h == v -> conta_linha(t, v, acc + 1)
      true -> conta_linha(t, v, acc)
    end
  end

  def test_conta_fechadas(n) do
    conta_fechadas(gera_tabuleiro(n))
  end

  # -- conta_minas/1: Recebe o tabuleiro de Minas (MBoard) e conta quantas minas existem no jogo

  def conta_minas([]), do: 0

  def conta_minas([h | t]) do
    conta_linha(h, true, 0) + conta_minas(t)
  end

  def test_conta_minas() do
    conta_minas(get_fake_mine_board())
  end

  # end_game?/2: recebe o tabuleiro de minas, o tauleiro do jogo, e diz se o jogo acabou.
  # O jogo acabou quando o número de casas fechadas é igual ao numero de minas
  def end_game(minas, tab), do: conta_fechadas(tab) == conta_minas(minas)

  #### fim do módulo
end

###################################################################
###################################################################

# A seguir está o motor do jogo!
# Somente descomentar essas linhas quando as funções do módulo anterior estiverem
# todas implementadas

defmodule Motor do
  def main() do
    v = IO.gets("Digite o tamanho do tabuleiro: \n")
    {size, _} = Integer.parse(v)
    minas = gen_mines_board(size)
    IO.inspect(minas)
    tabuleiro = Minesweeper.gera_tabuleiro(size)
    game_loop(minas, tabuleiro)
  end

  def game_loop(minas, tabuleiro) do
    IO.puts(Minesweeper.board_to_string(tabuleiro))
    v = IO.gets("Digite uma linha: \n")
    {linha, _} = Integer.parse(v)
    v = IO.gets("Digite uma coluna: \n")
    {coluna, _} = Integer.parse(v)

    if Minesweeper.is_mine(minas, linha, coluna) do
      IO.puts("VOCÊ PERDEU!!!!!!!!!!!!!!!!")
      IO.puts(Minesweeper.board_to_string(Minesweeper.abre_tabuleiro(minas, tabuleiro)))
      IO.puts("TENTE NOVAMENTE!!!!!!!!!!!!")
    else
      novo_tabuleiro = Minesweeper.abre_jogada(linha, coluna, minas, tabuleiro)

      if Minesweeper.end_game(minas, novo_tabuleiro) do
        IO.puts("VOCÊ VENCEU!!!!!!!!!!!!!!")
        IO.puts(Minesweeper.board_to_string(Minesweeper.abre_tabuleiro(minas, novo_tabuleiro)))
        IO.puts("PARABÉNS!!!!!!!!!!!!!!!!!")
      else
        game_loop(minas, novo_tabuleiro)
      end
    end
  end

  def gen_mines_board(size) do
    add_mines(ceil(size * size * 0.15), size, Minesweeper.gera_mapa_de_minas(size))
  end

  def add_mines(0, _size, mines), do: mines

  def add_mines(n, size, mines) do
    linha = :rand.uniform(size - 1)
    coluna = :rand.uniform(size - 1)

    if Minesweeper.is_mine(mines, linha, coluna) do
      add_mines(n, size, mines)
    else
      add_mines(n - 1, size, Minesweeper.update_pos(mines, linha, coluna, true))
    end
  end
end

Motor.main()
