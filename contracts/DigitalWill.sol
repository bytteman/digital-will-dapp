// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "hardhat/console.sol"; // For debugging

contract DigitalWill {
    // --- State Variables ---
    address public owner;
    address public executor;

    mapping(address => uint256) public beneficiaries;
    
    // Using a CID (Content Identifier) from IPFS for the will document
    string public willContentCID; 

    bool public isDeceased;
    uint256 public creationTime;
    uint256 public executionTime;

    // --- Events ---
    event WillCreated(address indexed owner, address indexed executor);
    event BeneficiaryAdded(address indexed beneficiary, uint256 amount);
    event OwnerDeclaredDeceased(address indexed executor, uint256 timestamp);
    event FundsDistributed(address indexed beneficiary, uint256 amount);

    // --- Modifiers ---
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    modifier onlyExecutor() {
        require(msg.sender == executor, "Only the executor can call this function.");
        _;
    }

    // --- Functions ---
    // The constructor is called only once when the contract is deployed.
    constructor(address _executor, string memory _willContentCID) payable {
        owner = msg.sender;
        executor = _executor;
        willContentCID = _willContentCID;
        creationTime = block.timestamp;
        emit WillCreated(owner, executor);
    }
    
    // Function to add or update a beneficiary's share
    function addOrUpdateBeneficiary(address _beneficiary, uint256 _amount) public onlyOwner {
        require(_beneficiary != address(0), "Invalid beneficiary address.");
        beneficiaries[_beneficiary] = _amount;
        emit BeneficiaryAdded(_beneficiary, _amount);
    }
    
    // Function to update the will document on IPFS
    function updateWillContent(string memory _newWillContentCID) public onlyOwner {
        willContentCID = _newWillContentCID;
    }

    // The executor triggers this function after the owner's passing.
    // !! THIS IS A HUGE SIMPLIFICATION (THE ORACLE PROBLEM) !!
    function declareDeceased() public onlyExecutor {
        require(!isDeceased, "The owner has already been declared deceased.");
        isDeceased = true;
        executionTime = block.timestamp;
        emit OwnerDeclaredDeceased(msg.sender, block.timestamp);
    }

    // The executor triggers the distribution of funds.
    function distributeFunds(address[] calldata _beneficiaryAddresses) public onlyExecutor {
        require(isDeceased, "Distribution can only happen after the owner is declared deceased.");
        require(address(this).balance > 0, "Contract has no funds to distribute.");

        uint256 totalPayout = 0;
        for (uint i = 0; i < _beneficiaryAddresses.length; i++) {
            address beneficiary = _beneficiaryAddresses[i];
            uint256 amount = beneficiaries[beneficiary];
            if (amount > 0) {
                totalPayout += amount;
            }
        }
        
        // Sanity check to ensure we have enough funds.
        require(totalPayout <= address(this).balance, "Insufficient funds in the contract for total payout.");

        // Distribute funds
        for (uint i = 0; i < _beneficiaryAddresses.length; i++) {
            address beneficiary = _beneficiaryAddresses[i];
            uint256 amount = beneficiaries[beneficiary];
            if (amount > 0) {
                // Remove the beneficiary to prevent re-entrancy attacks
                beneficiaries[beneficiary] = 0; 
                payable(beneficiary).transfer(amount);
                emit FundsDistributed(beneficiary, amount);
            }
        }
    }

    // Function to allow the contract to receive Ether
    receive() external payable {}
}