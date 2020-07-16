
pragma solidity ^0.4.23;

pragma experimental ABIEncoderV2;

contract Web_Of_Trust {
    
    // Avoid storing duplicates in the list
    mapping (address => mapping(address => bool)) trust_lookup;
    // Trust graph core
    mapping(address => address[]) trust_graph;

    // Hack to pass mapping as function argument
    struct map_struct {
        mapping(address => bool) visited;
    }

    // Senders trusts a target address
    function endorse_trust(address trusted_address) external {
        require(!trust_lookup[msg.sender][trusted_address]);
        require(msg.sender != trusted_address);
        trust_lookup[msg.sender][trusted_address] = true;
        trust_graph[msg.sender].length++;
        trust_graph[msg.sender][trust_graph[msg.sender].length - 1] = trusted_address; 
    }

    function revoke_trust(address untrusted_address) external {
        // The address is already trusted
        require(trust_lookup[msg.sender][untrusted_address]);
        trust_lookup[msg.sender][untrusted_address] = false;
        bool found_untrusted_address = false;
        for (uint256 i = 0; i < trust_graph[msg.sender].length - 1; i++) {

            if (trust_graph[msg.sender][i]==untrusted_address)
                found_untrusted_address = true;

            if (found_untrusted_address){
                trust_graph[msg.sender][i] =  trust_graph[msg.sender][i+1];
            }
        }
        delete trust_graph[msg.sender][trust_graph[msg.sender].length-1];
        trust_graph[msg.sender].length--;
    }

    function bfs(address target, address origin) public returns (int256) {
        map_struct storage ss;
        ss.visited[target] = true;
        address[] storage qq;
        qq.length++;
        qq[qq.length - 1] = origin;
        bool searching = true;
        int256 hops = 0;
        uint256 q_btm = 0;
        while (searching){
            address curr = qq[qq.length - 1];
            qq.length --;
            if (trust_lookup[curr][target]){
                hops += 1;
                searching = false;
            }
            for (uint256 i = 0; i < trust_graph[curr].length; i++){
                if (trust_graph[curr][i] == target)
                    searching = false;
                
                if (searching && !ss.visited[trust_graph[curr][i]]){
                    ss.visited[trust_graph[curr][i]] = true;
                    qq.length++;
                    qq[qq.length - 1] = trust_graph[curr][i];
                    hops += 1;
                }
            }
            if (searching && 0 == qq.length){
                return -1;
            }
        }
        
        return hops;
    }



    function hop_to_target(address target, address origin /*uint8 threshold*/) public returns (int256){
        map_struct storage ss;
        bool found;
        int256 hops;
        (hops,found) = hop_internal_rec(origin,target,ss);
        if (found)
            return hops;
        else
            return -1;
    }
    
    // TODO: Calculate Big O notation for the algorithm and write documentation :)

    function hop_internal_rec(address origin, address target, map_struct storage ss /*uint8 threshold*/)
            internal returns (int256,bool){
        ss.visited[origin] = true;
        if (origin == target)
            return (0,true);
        
        if (trust_lookup[origin][target])
            return (1,true);
        bool found = false;
        int256 hops = 10;
        for (uint256 i = 0; i < trust_graph[origin].length; i++){
            int256 curr_hops = 1;
            address nxt_node = trust_graph[origin][i];
            if (!ss.visited[nxt_node]){
                int256 req_hops;
                (req_hops,found) = hop_internal_rec(nxt_node,target,ss /*threshold*/);
                curr_hops += req_hops;
            }
            if (curr_hops < hops){
                hops = curr_hops;
            }
        }
        return (hops,found);
    }

    //====== Debug Functions & State ======//
    uint256 contract_version = 1;

    function set_version(uint256 cv_n) public {
        contract_version = cv_n;
    }

    function get_version() public view returns (uint256) {
        return contract_version;
    }

    function addr_to_string(address x) internal pure returns (string) {
        bytes memory b = new bytes(20);
        for (uint i = 0; i < 20; i++)
            b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
        return string(b);
    }

    function get_from_mapping(address t) public view returns (address){
        return trust_graph[t][0];
    }

    //===================================//
}





contract PQ {

    struct Node {
        int256 key;
        address value;
    }    
    /* 
     *  Storage
     */
    Node[7] private heapKeyValue;
    uint8 private current_size = 0;
    function insert(int256 key, address addr) public {

        if (current_size == 7) {
            uint8 indx;
            bool inserted;
            (inserted,indx) = find_replace_max(key,addr);
            if (inserted)
                heapify(indx);
        } else {
            heapKeyValue[current_size] = Node(key,addr);
            heapify(current_size);
            current_size += 1;
        }
    }

    function get_specific_key(uint8 i) public view returns (int256){
        require(i<=6);
        return heapKeyValue[i].key;
    }

    function get_specific_node(uint8 i) public view returns (Node){
        require(i<=6);
        return heapKeyValue[i];
    }

    function get_min_node() public view returns (Node) {
        return heapKeyValue[0];
    }

    function get_min_key() public view returns (int256){
        return heapKeyValue[0].key;
    }

    function heapify(uint8 idx) internal {
        if (idx == 0) return;
        uint8 curr_idx = idx;
        uint8 par_idx = curr_idx/2;
        while (heapKeyValue[curr_idx].key < heapKeyValue[par_idx].key ) {
            swap_values(curr_idx,par_idx);
            curr_idx = par_idx;
            par_idx = curr_idx/2; 
        }
    }

    function find_replace_max(int256 target_key, address addr) internal returns (bool,uint8) {
        uint8 max_pos = 8;
        int256 max_value = -10;
        for (uint8 i = 3; i < 7; i++){
            if (heapKeyValue[i].key > max_value){
                max_pos = i;
                max_value = heapKeyValue[i].key;
            }
        }
        if (target_key < max_value) {
            heapKeyValue[max_pos].key = target_key;
            heapKeyValue[max_pos].value = addr;
            return (true,max_pos);
        }
        return (false,max_pos);
    }

    function swap_values(uint8 lhs, uint8 rhs) internal {
        Node memory tmp = heapKeyValue[lhs];
        heapKeyValue[lhs] = heapKeyValue[rhs];
        heapKeyValue[rhs] = tmp;
    }

}

contract FirmwareRepo{

    // Firmware struct
    struct Firmware {
        // address developer;
        bytes32 firmware_hash;
        string IPFS_link;
        string description;
        uint256 block_number;
        // string device_type;
    }
    // Firmware Infor struct
    struct Firmware_Info {
        Firmware fw;
        address developer;
        int256 trust;
    }
    uint256 cv = 1;
    Web_Of_Trust web_trust;
    address web_trust_addr;

    mapping(string => mapping(address=>uint256)) device_developer_index;
    
    mapping(string => address[]) device_developers;
    
    // Each developer is allowed to have a stable version and a experimental version. Critical Assumption
    mapping(string => mapping(address => Firmware[2])) developed_firmware;


    // Modifiers
    // There exists firmware for the target device
    modifier hasFirmware(string device_type) {
        require(device_developers[device_type].length != 0);
        _; 
    }
    // The requested developer exists
    modifier isValidDeveloper(string device_type, address developer) {
        require(developed_firmware[device_type][developer][0].firmware_hash[0] != 0 ||
            developed_firmware[device_type][developer][1].firmware_hash[0] != 0);
        _; 
    }

    constructor() public {
        web_trust_addr = new Web_Of_Trust();
        web_trust = Web_Of_Trust(web_trust_addr);
        cv = 2;
    }

    /* Generic Interface (Setters/Getters) *
    ************************************/
    // Get Web of Trust Contract Address
    function trust_address() public view returns (address) {
        return web_trust_addr;
    }


    mapping(address => bytes32) current_challenge;
    mapping(address => uint) timeOfLastProof;
    mapping(address => uint) difficulty;
    function get_d() public view returns(uint) {return difficulty[msg.sender];}
    function get_t() public view returns(uint) {return timeOfLastProof[msg.sender];}
    function get_c() public view returns(bytes32) {return current_challenge[msg.sender];}

    function proofOfWork(uint nonce) public {
        
        // Calculate the difficulty
        uint timeSinceLastProof = (now - timeOfLastProof[msg.sender]);
        if (timeSinceLastProof > 1 days){
            // Reset Difficulty
            difficulty[msg.sender] = 10**77;
        } else{
            // Exponentiate Difficulty
            difficulty[msg.sender] = difficulty[msg.sender]/50;
        }
        bytes32 n = keccak256(abi.encode(nonce, current_challenge[msg.sender]));    // Generate a random hash based on input
        require(n <= bytes32(difficulty[msg.sender]));                 // Check if it's under the difficulty


        timeOfLastProof[msg.sender] = now;
        current_challenge[msg.sender] = keccak256(abi.encode(nonce,
                                                  current_challenge[msg.sender],
                                                  blockhash(block.number - 1)));  // Save a hash that will be used as the next proof
    }




    /** Interface Target for Developers *
    ************************************/

    /**
        * @dev Called by developers to add a new firmware to the contract.
        * @param firmware_hash_ Hash of the firmware using SHA-3
        * @param IPFS_link_ IPFS link to download the firmware
        * @param description_  Firmware description
        * @param device_type_  Device Type (E.g. Raspberry pi)
        * @param stable       Firmware type: LTS or Latest Version
    */
    function add_firmware(bytes32 firmware_hash_, string IPFS_link_,
        string description_, string device_type_, bool stable) public {
        require(firmware_hash_ != 0);
        require(!is_empty(IPFS_link_));
        require(!is_empty(description_));
        require(!is_empty(device_type_));
        uint8 firmware_index = (stable) ? 0 : 1;
        // If I have no firmware from that dev, then add him to the list
        if (developed_firmware[device_type_][msg.sender][0].firmware_hash[0] == 0 &&
            developed_firmware[device_type_][msg.sender][1].firmware_hash[0] == 0 ){
            uint256 prv_length = device_developers[device_type_].length;
            device_developers[device_type_].length++;
            device_developers[device_type_][prv_length] = msg.sender;
            device_developer_index[device_type_][msg.sender] = prv_length;
        }
        developed_firmware[device_type_][msg.sender][firmware_index] = 
            Firmware(firmware_hash_,IPFS_link_,description_,block.number);  
    }

    /**
        * @dev Called by developers to edit the description of an existing firmware.
        * @param description_ New firmware description
        * @param device_type  Device Type (E.g. Raspberry pi)
        * @param stable       Firmware type: LTS or Latest Version
    */

    function edit_description(string description_, string device_type, bool stable) public {
        //TODO: Add proper require()
        uint8 firmware_index = (stable) ? 0 : 1;
        require(!is_empty(developed_firmware[device_type][msg.sender][firmware_index].description));
        developed_firmware[device_type][msg.sender][firmware_index].description = description_;
    }

    // /** Interface Target for Nodes *
    // ************************************/

      /**
        * @dev Called by nodes to get a specific firmware.
        * @param device_type  Device Type (E.g. Raspberry pi)
        * @param mf_address   Firmware Developer PK
        * @param stable       Firmware type: LTS or Latest Version
    */
    function get_firmware(string device_type, address mf_address, bool stable)
              hasFirmware(device_type)
              isValidDeveloper(device_type,mf_address)
             public view returns (bytes32, string, string, uint256){
        uint8 firmware_index = (stable) ? 0 : 1;
        Firmware memory fw = developed_firmware[device_type][mf_address][firmware_index];
        return (fw.firmware_hash, fw.IPFS_link, fw.description, fw.block_number);
    }

    function get_developer(string device_type, uint256 i)
             hasFirmware(device_type)
             public view returns (address) {
        return device_developers[device_type][i];
    }

      /**
        * @dev Called by nodes to get a firmware from the most trusted developer.
        * @param device_type  Device Type (E.g. Raspberry pi)
        * @param stable       Firmware type: LTS or Latest Version
    */
    function get_most_trusted_firmware(string device_type, bool stable) hasFirmware(device_type)
             public returns (bytes32, string, string, uint256,address,int256) {
        address most_trusted_dev;
        int256  max_trust = -1;
        for (uint256 i = 0; i < device_developers[device_type].length; i++ ){
                                                        // Target                        ,Origin
            int256 curr_trust = web_trust.hop_to_target(device_developers[device_type][i], msg.sender);
            if (curr_trust > max_trust){
                max_trust = curr_trust;
                most_trusted_dev = device_developers[device_type][i];
            }
        }
        // Require to trust the developer
        require(max_trust != -1, "No trusted developer found :(");
        return fw_info_to_tuple(device_type,stable,most_trusted_dev,max_trust);
    }
    // /**
    //     * @dev Called by nodes to get a firmware from the 7 most trusted developers.
    //     * @param device_type  Device Type (E.g. Raspberry pi)
    //     * @param stable       Firmware type: LTS or Latest Version
    //       Requires transaction
    // */  
    // function get_top_firmwares(string device_type, bool stable)
    //     public returns (Firmware_Info[7]){
    //     uint8 firmware_index = (stable) ? 0 : 1;
    //     //address pq_address = new PQ();
    //     PQ pq;//= PQ(pq_address);
    //     for (uint256 i = 0; i < device_developers[device_type].length; i++ ){
    //         int256 curr_trust = web_trust.hop_to_target(device_developers[device_type][i]);
    //         pq.insert(curr_trust,device_developers[device_type][i]);
    //     }
    //     Firmware_Info[7] firmware_list;
    //     for (uint8 k = 0;  i < 7; i++){
    //         PQ.Node memory tmp = pq.get_specific_node(k);
    //         firmware_list[i] = Firmware_Info(developed_firmware[device_type][tmp.value][firmware_index],tmp.value,tmp.key);
    //     }
    //     return firmware_list;
    // }

    function fw_info_to_tuple(string device_type, bool stable, address most_trusted_dev, int256 trust)
        internal view  returns (bytes32, string, string, uint256, address, int256) {
        uint8 firmware_index = (stable) ? 0 : 1;
        return (developed_firmware[device_type][most_trusted_dev][firmware_index].firmware_hash,
            developed_firmware[device_type][most_trusted_dev][firmware_index].IPFS_link, 
            developed_firmware[device_type][most_trusted_dev][firmware_index].description,
            developed_firmware[device_type][most_trusted_dev][firmware_index].block_number,
            most_trusted_dev,
            trust);
    }

    /**
        * @dev Called internally to check if a string is empty
        * @param str  String to check
    */
    function is_empty(string str) internal pure returns (bool) {
        // Source: https://ethereum.stackexchange.com/questions/11039/how-can-you-check-if-a-string-is-empty-in-solidity
        bytes memory tempEmptyStringTest = bytes(str); // Uses memory
        return (tempEmptyStringTest.length == 0);
    }


    // Priority Q //
    struct Node {
        int256 key;
        address value;
    }    


    //====== Debug Functions & Debug State ======//

    function set_version(uint256 v) public returns (address) {
        cv = v;
        return msg.sender;
    }

    function get_version() public view returns (uint256) {
        return cv;
    }

    function set_trust_version(uint256 v) public {
        web_trust.set_version(v);   
    }

    function get_trust_version() public view returns (uint256){
        return web_trust.get_version();
    }
    //===================================//
}