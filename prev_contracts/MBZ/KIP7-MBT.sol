pragma solidity 0.5.6;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

interface IKIP7Receiver {
    function onKIP7Received(address _operator, address _from, uint256 _amount, bytes calldata _data) external returns (bytes4);
}

contract MBT {
    using SafeMath for uint256;
    using Address for address;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    address private _owner;

    string private _name;
    string private _symbol;
    uint8 private _decimals = 18;
    uint256 private _totalSupply;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (bytes4 => bool) private _supportedInterfaces;

    bytes4 private _KIP7_RECEIVED = 0x9d188c22;
    bytes4 private constant _INTERFACE_ID_KIP13 = 0x01ffc9a7;
    bytes4 private constant _INTERFACE_ID_KIP7 = 0x65787371;
    bytes4 private constant _INTERFACE_ID_KIP7_METADATA = 0xa219a025;
    bytes4 private constant _INTERFACE_ID_KIP7BURNABLE = 0x3b5a0bf8;

    // ======== mining ========
    address public distributor;
    uint256 public lastMined;
    uint256 public minableBlock;

    uint256 public blockAmount;

    uint256 public halfLife;
    uint256 public halving;
    uint256 public miningAmount;

    constructor(
        string memory name, // 이름
        string memory symbol, // 심볼
        uint256 _minableBlock, // 최소 블록 하이트
        uint256 _blockAmount, // 블록당 마이닝수 1MBT = 1000000000000000000
        uint256 _halfLife, // 반감기 몇 블록마다 반복할지
        uint256 _halving, // 반감기 횟수
        uint256 _miningAmount, // 최대 마이닝수 1MBT = 1000000000000000000 
        address initialSupplyClaimer, // 최초 발행 물량 받을 주소
        uint256 initialSupply // 최초 물량 금액 1MBT = 1000000000000000000
    ) public {
        _registerInterface(_INTERFACE_ID_KIP13);
        _registerInterface(_INTERFACE_ID_KIP7);
        _registerInterface(_INTERFACE_ID_KIP7_METADATA);
        _registerInterface(_INTERFACE_ID_KIP7BURNABLE);

        _owner = msg.sender;
        _name = name;
        _symbol = symbol;

        require(_minableBlock > block.number); // 마이닝 시작 시간 현재 블록 보다 높아야함
        minableBlock = _minableBlock;

        require(_blockAmount != 0);
        blockAmount = _blockAmount;

        halfLife = _halfLife;
        halving = _halving;
        miningAmount = _miningAmount;

        if(initialSupplyClaimer != address(0) && initialSupply != 0)
            _mint(initialSupplyClaimer, initialSupply);
    }
    ///////////////////////// ownable /////////////////////////
    modifier onlyOwner {
        require(msg.sender == _owner);
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    event SetDistributor(address indexed previousDistributor, address indexed newDistributor);
    function setDistributor(address _distributor) public onlyOwner {
        require(_distributor != address(0));
        emit SetDistributor(distributor, _distributor);
        distributor = _distributor;
    }
    ///////////////////////////////////////////////////////////

    ///////////////////////// mining /////////////////////////
    function mined() public view returns (uint256 res) {
        uint256 endBlock = block.number;
        uint256 startBlock = minableBlock;
        if (endBlock < startBlock) return 0;

        uint blockAmt = blockAmount;

        if(halfLife != 0){
            uint256 level = ((endBlock.sub(startBlock)).add(1)).div(halfLife);
            if(halving != 0) level = level > halving ? halving : level;

            for(uint256 i = 0; i < level; i++){
                if(startBlock.add(halfLife) > endBlock) break;

                res = res.add(blockAmt.mul(halfLife));
                startBlock = startBlock.add(halfLife);
                blockAmt = blockAmt.div(2);
            }
        }

        res = res.add(blockAmt.mul((endBlock.sub(startBlock)).add(1)));
        if(miningAmount != 0) res = res > miningAmount ? miningAmount : res;
    }

    modifier onlyDistributor {
        require(msg.sender == distributor);
        _;
    }

    event Mine(uint256 thisMined, uint256 lastMined, uint256 curMined);
    function mine() public onlyDistributor {
        uint256 curMined = mined(); 
        uint256 thisMined = curMined.sub(lastMined);
        if(thisMined == 0) return;

        emit Mine(thisMined, lastMined, curMined);

        lastMined = curMined;
        _mint(distributor, thisMined);
    }
    //////////////////////////////////////////////////////////

    ////////////////////// KIP7 Standard //////////////////////
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner_, address spender) public view returns (uint256) {
        return _allowances[owner_][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function safeTransfer(address recipient, uint256 amount) public {
        safeTransfer(recipient, amount, "");
    }

    function safeTransfer(address recipient, uint256 amount, bytes memory data) public {
        transfer(recipient, amount);
        require(_checkOnKIP7Received(msg.sender, recipient, amount, data), "KIP7: transfer to non KIP7Receiver implementer");
    }

    function safeTransferFrom(address sender, address recipient, uint256 amount) public {
        safeTransferFrom(sender, recipient, amount, "");
    }

    function safeTransferFrom(address sender, address recipient, uint256 amount, bytes memory data) public {
        transferFrom(sender, recipient, amount);
        require(_checkOnKIP7Received(sender, recipient, amount, data), "KIP7: transfer to non KIP7Receiver implementer");
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "KIP7: transfer from the zero address");
        require(recipient != address(0), "KIP7: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "KIP7: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "KIP7: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner_, address spender, uint256 value) internal {
        require(owner_ != address(0), "KIP7: approve from the zero address");
        require(spender != address(0), "KIP7: approve to the zero address");

        _allowances[owner_][spender] = value;
        emit Approval(owner_, spender, value);
    }

    function _checkOnKIP7Received(address sender, address recipient, uint256 amount, bytes memory _data)
        internal returns (bool)
    {
        if (!recipient.isContract()) {
            return true;
        }

        bytes4 retval = IKIP7Receiver(recipient).onKIP7Received(msg.sender, sender, amount, _data);
        return (retval == _KIP7_RECEIVED);
    }

    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "KIP13: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
    ///////////////////////////////////////////////////////////
}
