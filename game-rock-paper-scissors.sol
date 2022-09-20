pragma solidity ^0.5.0;

contract RockPaperScissors {
    address payable private player1;
    address payable private player2;
    string private choiceOfPlayer1;
    string private choiceOfPlayer2;
    bool private hasPlayer1MadeChoice;
    bool private hasPlayer2MadeChoice;
    
    // Khi tham gia game cần cược
    uint256 public stake; //tiền cược sẽ được hiển thị cho Người chơi 2

    // Một ma trận chứa kết quả của trò chơi dựa trên các trạng thái
    mapping(string => mapping(string => uint8)) private states;

    // Hàm tạo khởi tạo môi trường trò chơi
    constructor() public {
        states['R']['R'] = 0;
        states['R']['P'] = 2;
        states['R']['S'] = 1;
        states['P']['R'] = 1;
        states['P']['P'] = 0;
        states['P']['S'] = 2;
        states['S']['R'] = 2;
        states['S']['P'] = 1;
        states['S']['S'] = 0;

        stake = 1 ether;
    }
    
    // Modifiers
    
    modifier isJoinable() {
        require((msg.value >= 1000000000000000000),
                "So tiền cược phải lớn hơn 1"
        );
        require(player1 == address(0) || player2 == address(0),
                "Phòng đã đầy."
        );
        require((player1 != address(0) && msg.value == stake) || (player1 == address(0)), // Người chơi 1 có thể chọn tiền cược, người chơi 2 phải khớp. 
                "Bạn phải trả tiền đặt cược để chơi trò chơi."
        );
        _;
    }
    
    modifier isPlayer() {
        require(msg.sender == player1 || msg.sender == player2,
                "Bạn không chơi trò chơi này."
        );
        _;
    }
    
    modifier isValidChoice(string memory _playerChoice) {
        require(keccak256(bytes(_playerChoice)) == keccak256(bytes('R')) ||
                keccak256(bytes(_playerChoice)) == keccak256(bytes('P')) ||
                keccak256(bytes(_playerChoice)) == keccak256(bytes('S')) ,
                "Lựa chọn của bạn không hợp lệ, nó phải là một trong R, P và S."
        );
        _;
    }
    
    modifier playersMadeChoice() {
        require(hasPlayer1MadeChoice && hasPlayer2MadeChoice,
                "Người chơi chưa lựa chọn"
        );
        _;
    }

    // Functions
     
    function join() external payable 
        isJoinable // Để tham gia trò chơi, phải có một không gian trống
    {
        if (player1 == address(0)) {
            player1 = msg.sender;
            stake = msg.value; //Người chơi 1 xác định tiền cược
            
        } else
            player2 = msg.sender;
    }
    
    function makeChoice(string calldata _playerChoice) external 
        isPlayer()                      // Chỉ những người chơi mới có thể đưa ra lựa chọn
        isValidChoice(_playerChoice)    // Các lựa chọn phải hợp lệ
    {
        if (msg.sender == player1 && !hasPlayer1MadeChoice) {
            choiceOfPlayer1 = _playerChoice;
            hasPlayer1MadeChoice = true;
        } else if (msg.sender == player2 && !hasPlayer2MadeChoice) {
            choiceOfPlayer2 = _playerChoice;
            hasPlayer2MadeChoice = true;
        }
    }
    
    function disclose() external 
        isPlayer()          // Chỉ người chơi mới có thể tiết lộ kết quả trò chơi
        playersMadeChoice() // Có thể tiết lộ kết quả khi lựa chọn được thực hiện
    {
        // Disclose the game result
        int result = states[choiceOfPlayer1][choiceOfPlayer2];
        if (result == 0) {
            player1.transfer(stake); 
            player2.transfer(stake);
        } else if (result == 1) {
            player1.transfer(address(this).balance);
        } else if (result == 2) {
            player2.transfer(address(this).balance);
        }
        
        // Reset the game
        player1 = address(0);
        player2 = address(0);

        choiceOfPlayer1 = "";
        choiceOfPlayer2 = "";
        
        hasPlayer1MadeChoice = false;
        hasPlayer2MadeChoice = false;
        
        stake = 1 ether;
    }
}
