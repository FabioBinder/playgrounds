import SpriteKit

// Tem alguém lendo isso? Se você foi o primeiro, parabéns, faça a tarefa abaixo e venha pegar um chocolate comigo. ;)
// Tarefa: faça um post criativo e misterioso no Facebook com a hashtag #swiftfoolishchallenge

// Comentários gerais: o código não está uma lindeza mas é o que tem para hoje.
// Todos os identificadores estão em inglês pq pessoas descoladas não programam em português. :)

// Constantes gerais.
// Credo que xunxo maldito!
public enum Global {
    static public let BOARD_SIZE = 20
    static public let QTY_ELEMENTS = BOARD_SIZE * BOARD_SIZE
    static public let ELEMENT_SIZE = 31
}

enum Directions: Int {
    case SE = 0, SW = 1, NW = 2, NE = 3
}

// Representação de cada elemento.
// Poderia ter criado uma classe mas deu preguiça...
struct Element {
    var rotating: Bool          // indica se está rotacionando o elemento
    var reacting: Bool          // indica que uma reação deve ser verificada
    var animating: Bool         // indica que a animação de rotação terminou
    var direction: Directions   // estado atual do elemento: 0:SE, 1:SW, 2:NW, 3:NE
    var color: CGFloat          // valor do componente Green da cor, usado para mudar a cor lentamente
    // de amarelo para vermelho. Se representa o componente Green, pq não se chama green?
    var sprite: SKSpriteNode    // Sprite que corresponde ao elemento
}

// Cena, é aqui que tudo acontece
public class Scene :SKScene
{
    // Listas de frames para as animações de cada direção SE, SW, NW, NE
    var frames = Array(repeating: Array(repeating: SKTexture(), count: 4), count: 4)
    //[[SKTexture]]()
    
    // Textura geral, contém todos os frames
    var texture: SKTexture = SKTexture()
    
    // Matriz de elementos exibidos na view
    var elements:[Element] = [Element]()
    
    // Indica se uma reação teve início
    var start: Bool = false
    
    // Som tocado quando ocorre uma reação
    let soundAction = SKAction.playSoundFileNamed("som", waitForCompletion: false)
    
    // Tempo de exibição de cada frame
    let TIME_FRAME = 0.01
    
    // Quantidade total de frames do arquivo de imagem
    let QTY_FRAMES = 12
    
    
    // Inicialização da cena
    override public init(size: CGSize) {
        super.init(size: size)
        
        // Carga da textura.
        // Tsc, tsc. Se fosse um programador de verdade teria usado uma forma geométrica ao invés de uma figura.
        texture = SKTexture(imageNamed: "circs.png")
        
        // Configurações iniciais
        setupAnimations()
        setupBoard()
        
        // No início não há reação
        start = false
    }
    
    // Blerg, burocracia inútil. Really Apple?
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Configuração das animações, uma para cada estado
    // Essa função pega a imagem circs.png e recorta cada um dos frames para uso nas animações
    // Pq vc não utilizou um atlas? Não seria mais fácil?
    // Seria, agora pare de fazer perguntas embaraçosas e continue lendo o código
    func setupAnimations() {
        
        // Largura de cada frame
        let width = 1.0/Double(QTY_FRAMES)
        
        // Executa 12 vezes, uma para cada quadro
        for i in 0...QTY_FRAMES-1 {
            // Posição x do próximo frame dentro da textura original
            let x = Double(i)/Double(QTY_FRAMES)
            
            // Cada animação possui quatro quadros: o inicial que indica o estado atual, dois quadros de transição
            // e um quadro que indica o estado final
            if i>=0 && i<=3 {
                frames[Directions.SE.rawValue][i] = SKTexture(rect: CGRect(x: x, y: 0, width: width, height: 1), in: texture)
            }
            
            if i>=3 && i<=6 {
                frames[Directions.SW.rawValue][i-3] = SKTexture(rect: CGRect(x: x, y: 0, width: width, height: 1), in: texture)
            }
            
            if i>=6 && i<=9 {
                frames[Directions.NW.rawValue][i-6] = SKTexture(rect: CGRect(x: x, y: 0, width: width, height: 1), in: texture)
            }
            
            if i>=9 && i<=11 {
                frames[Directions.NE.rawValue][i-9] = SKTexture(rect: CGRect(x: x, y: 0, width: width, height: 1), in: texture)
            }
        }
        // O último quadro do estado NorthEast é igual ao primeiro quadro do estado SouthEast.
        // Que código deselegante esse aí de cima!
        // Eu sei, mas não consegui pensar em nada melhor. :(
        frames[Directions.NE.rawValue][3] = frames[Directions.SE.rawValue][0]
    }
    
    // Retorna o vetor de animação de acordo com a direção indicada como parâmetro
    func getAnimation ( _ direction: Directions) -> [SKTexture] {
        return frames[direction.rawValue]
    }
    
    // A partir da coluna (i) e da linha (j) da matriz que está sendo exibida na tela, calcula a posição do vetor onde
    // os elementos estão armazenados
    func index (_ i: Int, _ j: Int) -> Int {
        return j + i * Global.BOARD_SIZE
    }
    
    // Cria cada um dos elementos que devem ser exibidos na tela
    func setupBoard() {
        
        // Você é um péssimo programador, para que usar um loop duplo aqui?
        // Desculpe, como a tela é uma matriz, achei que seria mais fácil de entender. :(
        for i in 0...Global.BOARD_SIZE-1 {
            for j in 0...Global.BOARD_SIZE-1 {
                
                // Sorteia uma direção dentre as quatro possibilidades: SE, SW, NW e NE
                let direction: Directions = Directions(rawValue:Int.random(in: 0...3))!
                
                // Cria o sprite na direção sorteada
                let sprite = SKSpriteNode(texture: getAnimation(direction)[0])
                
                // Calcula a posição do elemento na tela
                sprite.position = CGPoint(x: Double(i*Global.ELEMENT_SIZE), y: -Double(j*Global.ELEMENT_SIZE))
                
                // Inicia com a cor branca.
                // Poderia ter usado .white aqui, seria mais fácil. Pare de reclamar! Que chatice! Vá postar alguma coisa inútil no Facebook.
                sprite.color = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
                
                // Como a cor do sprite será alterada e o sprite possui uma imagem o fator de blending deve ser diferente de zero
                // para que a cor do sprite seja misturada com as cores da imagem
                sprite.colorBlendFactor = 0.5
                
                // Cria o elemento e armazena-o no vetor de elementos
                elements.append(Element(rotating: false,
                                        reacting: false,
                                        animating: false,
                                        direction: direction,
                                        color: 1.0,
                                        sprite: sprite))
                
                // Adiciona o sprite do elemento atual na cena
                self.addChild(sprite)
            }
        }
    }
    
    // Executa a reação de um elemento
    func react (_ i: Int, _ j:Int) {
        
        // Calcula o índice do array com base na linha e coluna do elemento que deve reagir
        let index = self.index(i,j)
        
        // Rotação e animação vão começar
        self.elements[index].rotating = true;
        self.elements[index].animating = true;
        
        // Executa a animação. Foi utilizada uma ação que possui uma função que será chamada quando a animação terminar.
        // Adorei essa feature, assim fica tudo no mesmo local, facilitando o entendimento do programa! Uhuh!!! Programar é melhor que tudo!!!
        // Cara, você é doente
        // :(
        elements[index].sprite.run(SKAction.animate(with: getAnimation(elements[index].direction), timePerFrame: TIME_FRAME)) {
            
            // Indica que a animação terminou
            self.elements[index].animating = false
            
            // Caso a cor ainda não seja vermelha, diminui o componente "Green" do RGB.
            if self.elements[index].color > 0.0 {
                self.elements[index].color = self.elements[index].color - 0.1
                self.elements[index].sprite.color = UIColor(red: 1.0, green: self.elements[index].color, blue: 0.0, alpha: 1.0)
            }
        }
        
    }
    
    // Verifica se algum elemento deve executar sua reação
    func reaction() {
        
        // Indica se não há mais reações para executar
        var reaction_end = true
        
        for i in 0...Global.BOARD_SIZE-1 {
            for j in 0...Global.BOARD_SIZE-1 {
                
                // Se o elemento deve reagir, executa as verificações
                if elements[index(i,j)].reacting {
                    // Ao verificar as reações, indicar que o elemento não está mais reagindo
                    elements[index(i,j)].reacting = false
                    
                    // Existe elemento para reagir, não pode parar as animações
                    reaction_end = false
                    
                    // Para cada direção, executar as duas verificações possíveis
                    switch elements[index(i,j)].direction {
                        
                    case .SE:
                        west(i,j);
                        north(i,j);
                        
                    case .SW:
                        east(i,j);
                        north(i,j);
                        
                    case .NW:
                        east(i,j);
                        south(i,j);
                        
                    case .NE:
                        west(i,j);
                        south(i,j);
                    }
                    
                }
                    // Se o elemento está rotacionando, não pode parar as animações
                else if elements[index(i,j)].rotating {
                    reaction_end = false
                }
            }
        }
        
        // Atualiza o estado atual das reações
        start = !reaction_end
        
        // O que houve, acabaram as piadas?
        // Não, estou triste pois você me chamou de doente.
    }
    
    
    // Funções que verificam se uma reação deve ser executada em cada uma das quatro possíveis direções
    // Acho que tem maneira melhor de fazer isso... Eu também, mas não tive tempo de pensar.
    
    
    func west(_ i: Int, _ j: Int) {
        
        // Calcula o índice do array com base na linha e coluna do elemento que deve reagir
        let index = self.index(i+1,j)
        
        // Verifica apenas se não for o último elemento da coluna ...
        if i < Global.BOARD_SIZE-1 {
            
            // ... e se não estiver rotacionando
            if elements[index].rotating == false && (elements[index].direction == .SW || elements[index].direction == .NW) {
                react(i+1, j)
            }
        }
    }
    
    func east(_ i: Int, _ j: Int) {
        
        // Calcula o índice do array com base na linha e coluna do elemento que deve reagir
        let index = self.index(i-1,j)
        
        if (i > 0) {
            if elements[index].rotating == false  && (elements[index].direction == .SE || elements[index].direction == .NE) {
                react(i-1, j)
            }
        }
        
    }
    
    func north(_ i: Int, _ j: Int) {
        
        // Calcula o índice do array com base na linha e coluna do elemento que deve reagir
        let index = self.index(i,j+1)
        
        if (j < Global.BOARD_SIZE-1) {
            if elements[index].rotating == false && (elements[index].direction == .NE || elements[index].direction == .NW) {
                react(i, j+1)
            }
        }
    }
    
    func south(_ i: Int, _ j: Int) {
        
        // Calcula o índice do array com base na linha e coluna do elemento que deve reagir
        let index = self.index(i,j-1)
        
        if (j > 0) {
            if elements[index].rotating == false && (elements[index].direction == .SE || elements[index].direction == .SW) {
                react (i, j-1)
            }
        }
    }
    
    // Verifica em qual elemento o dedo dedou.
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Ao tocar em algum lugar da tela, iniciar uma reação
        start = true
        
        // Recupera o primeiro dedo que dedou na tela
        let touch = touches.first!
        
        // Informa qual a coordenada em que o dedo dedou.
        let location = touch.location(in: self)
        
        // A partir da posição x,y da tela onde ocorreu o toque, calcula a coluna e a linha da matriz que armazena os elementos
        let i = Int((abs(location.x)+13.5)/CGFloat(Global.ELEMENT_SIZE))
        let j = Int((abs(location.y)+13.5)/CGFloat(Global.ELEMENT_SIZE))
        
        // Executa a reação nas coordenadas onde o toque ocorreu
        react(i, j)
    }
    
    // Função executada no "Game Loop", é neste local que devem ser chamadas as funções que atualizem elementos da tela
    public override func update(_ currentTime: TimeInterval) {
        
        // Se uma reação está ocorrendo, verificar quais elementos devem reagir
        if start {
            reaction()
            
            // Quando uma animação terminar, indicar que uma reação deve ser verificada
            for i in 0...Global.BOARD_SIZE-1 {
                for j in 0...Global.BOARD_SIZE-1 {
                    
                    // Animação terminou
                    if self.elements[index(i,j)].rotating && !self.elements[index(i,j)].animating {
                        // Para a rotação
                        self.elements[index(i,j)].rotating = false
                        
                        // Indica que uma reação deve ser verificada
                        self.elements[index(i,j)].reacting = true
                        
                        // Atualiza a direção. O resto da divisão por 4 foi usado para garantir que os únicos resultados possíveis sejam 0, 1, 2 e 3
                        // Ei, gostei disso, legal!
                        // Obrigado, você é muito gentil. :D
                        self.elements[index(i,j)].direction = Directions(rawValue: (self.elements[index(i,j)].direction.rawValue+1) % 4)!
                        
                        // Executa o som de reação
                        if !self.hasActions() {
                            self.run(self.soundAction)
                        }
                    }
                }
            }
        } // <- Que nojo! Essa chave não está identada, pq?
        // Para ver se você estava prestando atenção
    }
}

// No geral seu código é um lixo, redundante e suas piadas não tem graça. Você deveria tentar outra profissão, acendedor de lampiões seria uma boa.
// Ok. Mas eu sou limpinho...


