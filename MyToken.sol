// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IERC20.sol";

contract MyToken is IERC20 {
    // Informations publiques du token
    string public name;
    string public symbol;
    uint8 public decimals;

    // Total supply interne
    uint256 private _totalSupply;

    // Mapping des soldes
    mapping(address => uint256) public balanceOf;

    // Mapping des allowances
    mapping(address => mapping(address => uint256)) public allowance;

    // BONUS : Événements ERC-20 standard
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Propriétaire du contrat (pour mint)
    address public owner;

    // -------------------------
    //        CONSTRUCTEUR
    // -------------------------
    constructor() {
        name = "MyToken";
        symbol = "MTK";
        decimals = 18;

        owner = msg.sender;

        // total supply fixe : 1,000,000 tokens (1e6 * 10^18)
        _totalSupply = 1_000_000 * (10 ** decimals);

        // Tous les tokens pour le déployeur
        balanceOf[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    // -------------------------
    //       FONCTIONS ERC20
    // -------------------------

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    // balanceOff already exist par defaut because 
    // Solidity automatically generates a getter function 
    // for public state variables

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        require(msg.sender != address(0), "Transfer from zero address");
        require(recipient != address(0), "Transfer to zero address");
        require(balanceOf[msg.sender] >= amount, "Balance too low");

        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // allowance already exist par defaut because 
    // Solidity automatically generates a getter function 
    // for public state variables


    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        require(msg.sender != address(0), "Approve from zero address");
        require(spender != address(0), "Approve to zero address");

        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        require(sender != address(0), "Transfer from zero");
        require(recipient != address(0), "Transfer to zero");
        require(balanceOf[sender] >= amount, "Balance too low");
        require(allowance[sender][msg.sender] >= amount, "Allowance too low");

        // Mise à jour des soldes
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;

        // Réduction de l'allowance
        allowance[sender][msg.sender] -= amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }

    // -------------------------
    //            BONUS
    // -------------------------

    // Mint réservé au propriétaire
    function mint(uint256 amount) external {
        require(msg.sender == owner, "Not owner");

        _totalSupply += amount;
        balanceOf[owner] += amount;

        emit Transfer(address(0), owner, amount);
    }

    // Burn : détruire ses propres tokens
    function burn(uint256 amount) external {
        require(balanceOf[msg.sender] >= amount, "Not enough to burn");

        balanceOf[msg.sender] -= amount;
        _totalSupply -= amount;

        emit Transfer(msg.sender, address(0), amount);
    }
}
