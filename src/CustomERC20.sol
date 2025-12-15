// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CustomERC20 {
    // =====================
    // ERC20 STORAGE
    // =====================
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowed;

    uint256 private _totalSupply;

    string public name;
    string public symbol;
    uint8 public immutable decimals;

    address public owner;

    // =====================
    // FEE MECHANISM
    // =====================
    uint256 public transferFeeBP; // basis points (100 = 1%)
    uint256 public constant MAX_FEE_BP = 500; // max 5%

    mapping(address => bool) public isFeeExempt;

    // =====================
    // EVENTS
    // =====================
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event FeeUpdated(uint256 newFeeBP);
    event FeeExemptSet(address indexed account, bool exempt);

    // =====================
    // MODIFIERS
    // =====================
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // =====================
    // CONSTRUCTOR
    // =====================
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        owner = msg.sender;

        _totalSupply = initialSupply;
        balances[owner] = initialSupply;

        isFeeExempt[owner] = true;

        emit Transfer(address(0), owner, initialSupply);
    }

    // =====================
    // ERC20 STANDARD
    // =====================
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function allowance(address _owner, address spender) public view returns (uint256) {
        return allowed[_owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(allowed[from][msg.sender] >= amount, "Allowance exceeded");
        allowed[from][msg.sender] -= amount;
        _transfer(from, to, amount);
        return true;
    }

    // =====================
    // INTERNAL TRANSFER LOGIC (WITH FEE)
    // =====================
    function _transfer(address from, address to, uint256 amount) internal {
        require(to != address(0), "Invalid address");
        require(balances[from] >= amount, "Insufficient balance");

        uint256 fee = 0;

        if (!isFeeExempt[from] && transferFeeBP > 0) {
            fee = (amount * transferFeeBP) / 10_000;
        }

        uint256 amountAfterFee = amount - fee;

        balances[from] -= amount;
        balances[to] += amountAfterFee;

        if (fee > 0) {
            balances[owner] += fee;
            emit Transfer(from, owner, fee);
        }

        emit Transfer(from, to, amountAfterFee);
    }

    // =====================
    // OWNER FUNCTIONS
    // =====================
    function setTransferFee(uint256 feeBP) external onlyOwner {
        require(feeBP <= MAX_FEE_BP, "Fee too high");
        transferFeeBP = feeBP;
        emit FeeUpdated(feeBP);
    }

    function setFeeExempt(address account, bool exempt) external onlyOwner {
        isFeeExempt[account] = exempt;
        emit FeeExemptSet(account, exempt);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _totalSupply += amount;
        balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function burn(uint256 amount) external onlyOwner {
        require(balances[owner] >= amount, "Insufficient balance");
        balances[owner] -= amount;
        _totalSupply -= amount;
        emit Transfer(owner, address(0), amount);
    }
}
