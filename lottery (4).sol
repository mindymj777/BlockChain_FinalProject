// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GuessTheNumber {
    address public owner;
    uint256[] private secretNumber;
    address[] private guessTimes;

    bool public gameEnded;

    mapping(address => uint256) public guesses;

    event GameEnded(address winner, uint256[]secretNumber);
    event IncorrectGuess(address player, uint256 a, uint256 b);

    constructor() payable {
        require(msg.value >= 10 ether, "Minimum bet is 10 ether");
        owner = msg.sender;
        secretNumber =  generateSecretNumber();
        gameEnded=false;
       
    }

    function generateSecretNumber() private view returns (uint256[] memory) {
        uint256[] memory digits = new uint256[](10);
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, block.coinbase,block.number, msg.sender)));

        digits[0] = (randomNumber % 9) + 1;

        for (uint256 i = 1; i < 3; i++) {
            randomNumber = uint256(keccak256(abi.encodePacked(randomNumber, block.timestamp)));
            uint256 digit = (randomNumber % 9) + 1;
            uint256 j = 0;
            while (j < i) {
                if (digits[j] == digit) {
                    j = 0;
                    randomNumber++;
                    digit = (randomNumber % 9) + 1;
                } else {
                    j++;
                }
            }
            digits[i] = digit;
        }

        return digits;
    }

    function calculateAB(uint256[] memory number) private view returns (uint256, uint256) {
        uint256 a = 0;
        uint256 b = 0;
        for (uint256 i = 0; i < 3; i++) {
            for (uint256 j = 0; j < 3; j++) {
                if (number[i] == secretNumber[j]) {
                    if (i == j) {
                        a++;
                    } else {
                        b++;
                    }
                }
            }
        }
        return (a, b);
    }

    function guess(uint256 number1,uint256 number2,uint256 number3) public payable {
        require(!gameEnded, "The game has ended");   
        require(msg.value >= 5 ether, "Minimum bet is 5 ether");
        require(msg.sender != owner, "Access denied. Owner can not call this function");    
        require(number1 < 9 && number2 <9 && number3 <9 , "The numbers are 0-9");


        guessTimes.push(msg.sender);

        uint256 guessNumber = (number1 * 100) + (number2 * 10) + number3;

        guesses[msg.sender] = guessNumber;

        uint256[] memory number=new uint256[](3);
        number[0]=number1;
        number[1]=number2;
        number[2]=number3;
        
        (uint256 a,uint256 b) = calculateAB(number);

        if (a==3) {
            payable(msg.sender).transfer(address(this).balance);
            gameEnded = true;
            emit GameEnded(msg.sender, secretNumber);
        } else {
            
            emit IncorrectGuess(msg.sender, a, b);
        }
    }

   

    function ToTalNumberGuesses() public view returns (uint256){
        return guessTimes.length;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Access denied. Only owner can call this function");
        _;
    }
    function getSecretNumber() public onlyOwner view returns (uint256,uint256,uint256) {
        return (secretNumber[0],secretNumber[1],secretNumber[2]);
    }
}
