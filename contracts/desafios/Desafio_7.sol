// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
REPETIBLE CON LÍMITE, PREMIO POR REFERIDO

* El usuario puede participar en el airdrop una vez por día hasta un límite de 10 veces

* Si un usuario participa del airdrop a raíz de haber sido referido, el que refirió gana 3 días adicionales para poder participar

* El contrato Airdrop mantiene los tokens para repartir (no llama al `mint` )

*(</) El contrato Airdrop tiene que verificar que el `totalSupply`  del token no sobrepase el millón

* El método `participateInAirdrop` le permite participar por un número random de tokens de 1000 - 5000 tokens
*/

interface IMiPrimerTKN {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract AirdropTwo is Pausable, AccessControl {
    // instanciamos el token en el contrato
    IMiPrimerTKN miPrimerToken;
    address public miPrimerTokenAdd;

    uint256 public constant totalSupply = 1 ** 6 * 10 ** 18;
    
    mapping(address => ReferUser) public referidos;
    mapping (address billetera => uint256 participaciones) participanteSinReferir;
    mapping(uint256 => mapping(address => bool)) participacionesDiarias;

    
    struct ReferUser {
        address billetera;
        uint256 participaciones;
        uint256 limiteParticipaciones;
        uint256 ultimaVezParticipado;
    }


    constructor(address _tokenAddress) {
        miPrimerTokenAdd = _tokenAddress;
        miPrimerToken = IMiPrimerTKN(miPrimerTokenAdd);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

    }

    function participateInAirdrop() public {
        //No participar dentro del mismo día 
        uint256 today = block.timestamp / 1 days;
        require(!participacionesDiarias[today][msg.sender], "Ya participaste en el ultimo dia");


        //Balance de Tokens del contrato
        uint256 balanceContrato = miPrimerToken.balanceOf(address(this));

        //Balance mínimo para repartir
        uint256 minimoParaRepartil = 1 ** 3 * 10 ** 18;

        //Verificamos que el contrato tenga tokens
        require(balanceContrato > minimoParaRepartil, "El contrato Airdrop no tiene tokens suficientes");

        //El perador ternario que verifica si participanteSinReferir[msg.sender] 
        //es diferente de 0. Si es así,se incrementa en 1. Si es igual a 0, se establece en 1
        participanteSinReferir[msg.sender] = participanteSinReferir[msg.sender] != 0 ? participanteSinReferir[msg.sender] + 1 : 1;

        //Verifica si se ha llegado al límite de participaciones
        require(participanteSinReferir[msg.sender] < 11, "Llegaste limite de participaciones");

        // Marcar al usuario como participante de hoy
        participacionesDiarias[today][msg.sender] = true;

        // Inicializar el struct ReferUser
        ReferUser storage _participante = referidos[msg.sender];
        _participante.billetera = msg.sender;
        _participante.participaciones = 1;
        _participante.limiteParticipaciones = 10;
        _participante.ultimaVezParticipado = today;

        
    }

    function participantes(address participante) public view returns (address, uint256, uint256, uint256){
        ReferUser storage user = referidos[participante];
    return (user.billetera, user.participaciones, user.limiteParticipaciones, user.ultimaVezParticipado);
    }

    function participateInAirdrop(address _elQueRefirio) public {
        // Obtenemos el participante y el referido
        ReferUser storage _participante = referidos[msg.sender];
        ReferUser storage _referido = referidos[_elQueRefirio];
        
        // Si el referido existe, le damos 3 días adicionales para participar
        if (_referido.billetera != address(0)) {
        _referido.limiteParticipaciones += 3;
        }

        // No participar dentro del mismo día 
        uint256 today = block.timestamp / 1 days;
        require(_participante.ultimaVezParticipado < today, "Ya participaste en el ultimo dia");

        //No se puede referir a sí mismo
        require(msg.sender != _elQueRefirio, "No puede autoreferirse");

        // Si el que refirió no existe, inicializarlo
        if (referidos[_elQueRefirio].billetera == address(0)) {
            referidos[_elQueRefirio].billetera = _elQueRefirio;
            referidos[_elQueRefirio].participaciones = 0;
            referidos[_elQueRefirio].limiteParticipaciones = 13;
            referidos[_elQueRefirio].ultimaVezParticipado = today;
        } 
    }

    ///////////////////////////////////////////////////////////////
    ////                     HELPER FUNCTIONS                  ////
    ///////////////////////////////////////////////////////////////

    function _getRadomNumber10005000() internal view returns (uint256) {
        return
            (uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) %
                4000) +
            1000 +
            1;
    }

    function setTokenAddress(address _tokenAddress) external {
        miPrimerToken = IMiPrimerTKN(_tokenAddress);
    }

    function transferTokensFromSmartContract()
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        miPrimerToken.transfer(
            msg.sender,
            miPrimerToken.balanceOf(address(this))
        );
    }
}
