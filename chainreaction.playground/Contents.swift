//Reação em cadeia
import SpriteKit
import PlaygroundSupport

// Criação da cena de acordo com o tamanho da constante BOARD_SIZE
var sceneSize = CGSize(width: Global.BOARD_SIZE * Global.ELEMENT_SIZE, height: Global.BOARD_SIZE * Global.ELEMENT_SIZE)

// Cálculo do ponto de origem
var pontoDeOrigem = CGPoint(x: 0.5/Double(Global.BOARD_SIZE), y: 1.0-0.5/Double(Global.BOARD_SIZE))

// Criação e configuração da cena
let view = SKView(frame: CGRect(x: 0, y: 0, width: sceneSize.width, height: sceneSize.height))
let scene = Scene(size: sceneSize)
scene.backgroundColor = SKColor.black
scene.anchorPoint = pontoDeOrigem

PlaygroundPage.current.liveView = view
PlaygroundPage.current.needsIndefiniteExecution = true

// Apresentação da cena
view.presentScene(scene)







