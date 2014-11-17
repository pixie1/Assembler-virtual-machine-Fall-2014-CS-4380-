#define _CRT_SECURE_NO_WARNINGS

#include <iostream>
#include <string>
#include <fstream>
#include <map>
#include <set>
#include <vector>

using namespace std;

struct ByteCode{
	int opcode;
	int operand1;
	int operand2;
};

bool isRegister(string);
bool isInteger(string);
bool isLabel(string);
int getRegister(string);
vector<string> parseInstruction(string);
bool checkInstructionSyntax(vector<string>, int);
bool checkTypeSyntax(vector<string>, int);
bool generateByteCode(vector<string>, char*, int, map<string, int>&, int);
bool loadData(vector<string>, char*, int&, int);
int firstPass(ifstream&, char*, map<string, int>&);
void secondPass(ifstream&, char*, map<string, int>&, int);
bool virtualMachine(char*, int);

const int INSTR_SIZE = 12;
const int CHAR_SIZE = 1;
const int INT_SIZE = 4;

int main(int argc, char* argv[]){

	char memory[1000001];
	map<string, int> symbolTable;
	
/*	if (argc != 2){
		cout << "no assembly file";
		exit(1);
	}
	string filename = argv[1];*/
	string filename = "proj3.asm";
	ifstream in(filename);
	if (!in){
		cout << "File did not open";
		exit(1);
	}
	//read file
	int instrStartPos=firstPass(in, memory, symbolTable);
		in.close();

	//2nd pass
	in.open(filename);
	secondPass(in, memory, symbolTable, instrStartPos);
	in.close();

	//VIRTUAL MACHINE
	bool success= virtualMachine(memory, instrStartPos);
	if (success)
		exit(0);
	else {
		cout << "Error processing byte code";
		exit(1);
	}

}

int firstPass(ifstream& in, char* memory, map<string,int>& symbolTable){
	set<string> command = { "AND", "OR","ADI","MOV", "LDR","LDA", "STR", "LDB", "STB", "DIV", "MUL", "SUB", "ADD", "TRP", "JMP", "JMR","BNZ","BGT","BLT", "BRZ", "CMP" };
	set<string> type = { ".INT", ".BYT" };
	string instructionLine;
	getline(in, instructionLine);
	int memPos = 0;
	int instrStartPos = 0;
	bool finishedReadingData = false;
	while (in){ //assembler pass 1
		if (!instructionLine.empty()){
			//break string into token
			vector<string> token = parseInstruction(instructionLine);
			if (token.size() != 0){
				//check if first token is operator or type
				int startPosition; //0 or 1 depending if label is present or not
				if (command.find(token[0]) == command.end() && type.find(token[0]) == type.end()){
					//not a command, this is a label or comment
					if (token[0][0] == ';') //comment  CHECK IF CAN REMOVE
						break;
					//check that label does not already exist
					if (symbolTable.find(token[0]) != symbolTable.end()){
						cout << "duplicate label";
						exit(1);
					}
					symbolTable.insert(pair<string, int>(token[0], memPos));
					startPosition = 1;
				}
				else{
					startPosition = 0;
				}
				//check the next token is instruction or type otherwise syntax error
				if (command.find(token[startPosition]) != command.end()){ //we are reading an instruction
					if (finishedReadingData == false){
						finishedReadingData = true;
						instrStartPos = memPos;
					}
					if (checkInstructionSyntax(token, startPosition))
						memPos += INSTR_SIZE;
					else{
						cout << instructionLine << " syntax error" << endl;
						exit(1);
					}
				}
				else if (type.find(token[startPosition]) != type.end()){
					//data will be inserted, check if int or byte
					if (checkTypeSyntax(token, startPosition)){
						if (token[startPosition] == ".BYT")
							memPos += CHAR_SIZE;
						else
							memPos += INT_SIZE;
					}
					else{
						cout << instructionLine << " syntax error" << endl;
						exit(1);
					}
				}
				else{
					cout << instructionLine << " syntax error" << endl;
					exit(1);
				}
			}
		}
		getline(in, instructionLine);
	}
	if (!in.ios::eof()) {
		cout << "error reading the file";
		exit(1);
	}
	return instrStartPos;
}

void secondPass(ifstream& in, char* memory, map<string, int>& symbolTable, int instrStartPos){
	string instructionLine;
	set<string> command = { "ADI","MOV", "LDR", "LDA", "STR", "LDB", "STB", "DIV", "MUL", "SUB", "ADD", "TRP", "JMP", "JMR", "BNZ", "BGT", "BLT", "BRZ", "CMP", "AND", "OR" };
	set<string> type = { ".INT", ".BYT" };
	int memPos = 0;
	getline(in, instructionLine);
	
	while (in){
		if (!instructionLine.empty()){
			//break string into token
			vector<string> token = parseInstruction(instructionLine);
			if (token.size() != 0){
				//check if first token is operator or type
				auto it = command.find(token[0]);
				auto it1 = type.find(token[0]);
				int startPosition; //1 or 0 depending on whether line starts with label or not
				if (it == command.end() && it1 == type.end()){
					//not a command, this is a label or comment
					if (token[0][0] == ';') //comment  should have been removed earlier, this is just in case
						break;
					//check that label  exist
					if (symbolTable.find(token[0]) == symbolTable.end()){
						cout << "label does not exist";
						exit(1);
					}
					startPosition = 1;
				}
				else{//line has no label
					startPosition = 0;
				}
				//check the token at startPosition is instruction or type otherwise syntax error
				if (memPos < instrStartPos){ //should be directive
					if (type.find(token[startPosition]) != type.end()){
						//data will be inserted, check if int or byte
						if (checkTypeSyntax(token, startPosition)){
							loadData(token, memory, memPos, startPosition);
						}
						else{
							cout << instructionLine << " syntax error" << endl;
							exit(1);
						}
					}
					else {
						cout << instructionLine << "incorrect instruction or instruction in midde of data";
						exit(1);
					}
				}
				else{
					it = command.find(token[startPosition]);
					if (it != command.end()){ //we are reading an instruction
						//generate byte code
						if (generateByteCode(token, memory, memPos, symbolTable, startPosition))
							memPos += INSTR_SIZE;
						else{
							cout << instructionLine << " syntax error" << endl;
							exit(1);
						}
					}
					else{
						cout << instructionLine << " syntax error" << endl;
						exit(1);
					}
				}
			}
		}
		getline(in, instructionLine);
	}
}

bool virtualMachine(char* memory, int instrStartPos){
	//reg[9]=SL, reg[10]=SP, reg[11]=FP, reg[12]=SB
	int reg[13];
	reg[8] = instrStartPos; // reg[8] contains PC
	reg[12] = 1000000; //stack bottom
	reg[9] = 500000; //stack limit record the length of data + code to change this
	bool running = true;
	while (running){
		//fetch instruction
		ByteCode* instruction;
		instruction = reinterpret_cast<ByteCode*>(memory + reg[8]);
		reg[8] += INSTR_SIZE;
		switch (instruction->opcode){
		case 0: //trap
			switch (instruction->operand1){
			case 0: 
				running = false;
				break;
			case 1: //write integer to standard out  TRAP uses register 7
				cout << reg[7];
				break;
			case 2://read integer from standard in
				cin >> reg[7];
				break;
			case 3: //write character to standard out
				cout << (char)reg[7];
				break;
			case 4: //read character from standard in. TEST THIS
				reg[7]=getchar();
				break;

			case 99:
				cout << "debug"<<endl;
				
				for (int i = 0; i < 24; i += 4){
					int* temp;
					temp = reinterpret_cast<int*>(memory + i);
					cout <<*temp << endl;
				}
				cout << "c: ";
				for (int i = 24; i < 31; i++){
					cout << memory[i] << " ";
				}
				break;
			default:
				cout << "invalid trap instruction";
				exit(1);
			}
			break;
		case 1://JMP
			reg[8] = instruction->operand1;
			break;
		case 2://JMR branch to adress in source register
			reg[8] = reg[instruction->operand1];
			break;
		case 3://BNZ 
			if (reg[instruction->operand1] != 0)
				reg[8] = instruction->operand2;
			break;
		case 4://BGT
			if (reg[instruction->operand1] > 0)
				reg[8] = instruction->operand2;
			break;
		case 5://BLT
			if (reg[instruction->operand1] < 0)
				reg[8] = instruction->operand2;
			break;
		case 6://BRZ
			if (reg[instruction->operand1] == 0)
				reg[8] = instruction->operand2;
			break;
		case 7://MOV
			reg[instruction->operand1] = reg[instruction->operand2];
			break;
		case 8://LDA
			reg[instruction->operand1] = instruction->operand2;
			break;
		case 9://STR
			memcpy(memory + instruction->operand2, &(reg[instruction->operand1]), sizeof(int));
			break;
		case 10://LDR
			int* temp;
			temp = reinterpret_cast<int*>(memory + instruction->operand2);
			reg[instruction->operand1] = *temp;
			break;
		case 11: //STB
			memory[instruction->operand2] = reg[instruction->operand1];
			break;
		case 12://LDB
			reg[instruction->operand1] = memory[instruction->operand2];
			break;
		case 13://ADD
			reg[instruction->operand1] += reg[instruction->operand2];
			break;
		case 14: //ADI
			reg[instruction->operand1] += instruction->operand2;
			break;
		case 15://SUB
			reg[instruction->operand1] -= reg[instruction->operand2];
			break;
		case 16://MUL
			reg[instruction->operand1] = reg[instruction->operand1] * reg[instruction->operand2];
			break;
		case 17://DIV
			reg[instruction->operand1] = reg[instruction->operand1] / reg[instruction->operand2];
			break;
		case 18: //AND
			if (reg[instruction->operand1] && reg[instruction->operand2])
				reg[instruction->operand1] = 1;
			else
				reg[instruction->operand1] = 0;
			break;
		case 19: //OR
			if (reg[instruction->operand1] || reg[instruction->operand2])
				reg[instruction->operand1] = 1;
			else
				reg[instruction->operand1] = 0;
			break;
		case 20://CMP
			if (reg[instruction->operand1] == reg[instruction->operand2])
				reg[instruction->operand1] = 0;
			else if (reg[instruction->operand1] > reg[instruction->operand2])
				reg[instruction->operand1] = 1;
			else if (reg[instruction->operand1] < reg[instruction->operand2])
				reg[instruction->operand1] = -1;
			break;
		case 21: //STR indirect adressing mode
			memcpy(memory + reg[instruction->operand2], &(reg[instruction->operand1]), sizeof(int));
			break;
		case 22: //LDR
			temp = reinterpret_cast<int*>(memory + reg[instruction->operand2]);
			reg[instruction->operand1] = *temp;
			break;
		case 23: //STB
			memory[reg[instruction->operand2]] = reg[instruction->operand1];
			break;
		case 24://LBD
			reg[instruction->operand1] = memory[reg[instruction->operand2]];
			break;
		default:
			cout << "invalid opcode";
			exit(1);
		}
	}
	return true;
}

bool checkInstructionSyntax(vector<string> token, int start){
	//start=0 if no+ label =1 if label
	//count: # of token in array, including the label
	//need operator - operand -operand unless it is a trap
	if ((token.size()-start) > 3)
		return false;
	//instruction Register register
	if (token[start] == "ADD"||token[start]=="SUB" ||token[start]=="DIV" ||token[start]=="MUL" || token[start]=="MOV" || token[start]=="CMP" 
		|| token[start]=="OR" || token[start]=="AND"){
		if ((token.size() - start) != 3) return false;
		if (!isRegister(token[start + 1])) return false;
		if (!isRegister(token[start + 2])) return false;
		return true;
	}
	if (token[start] == "ADI"){
		if ((token.size() - start) != 3) return false;
		if (!isRegister(token[start + 1])) return false;
		if (!isInteger(token[start + 2])) return false;
		return true;
	}

	//can be instruction register label or register register
	if (token[start] == "LDB" || token[start] == "LDR" || token[start] == "STB" || token[start] == "STR"){
		if ((token.size() - start) != 3) return false;
		if (!isRegister(token[start + 1])) return false;
		if (!isRegister(token[start + 2])&& !isLabel(token[start+2])) return false;
		return true;
	}
	//instruction register label
	if (token[start] == "LDA" ||token[start]=="BNZ" || token[start]=="BGT" || token[start]=="BLT"||token[start]=="BRZ"){
		if ((token.size() - start) != 3) return false;
		if (!isRegister(token[start + 1])) return false;
		if (!isLabel(token[start + 2])) return false;
		return true;
	}
	//instruction label
	if (token[start] == "JMP"){
		if ((token.size() - start) != 2) return false;
		if (!isLabel(token[start + 1])) return false;
		return true;
	}
	//instruction register
	if (token[start] == "JMR"){
		if ((token.size() - start) != 2) return false;
		if (!isRegister(token[start + 1])) return false;
		return true;
	}

	//instruction integer
	if (token[start] == "TRP"){
		if ((token.size() - start)!=2) return false;
		if (!isInteger(token[start + 1])) return false;
		return true;
	}

	return false;
}

vector<string> parseInstruction(string instructionLine){
	char * cstr = new char[instructionLine.length() + 1];
	strcpy(cstr, instructionLine.c_str());
	char * p = strtok(cstr, ",\t  ");
	vector<string> token;
	int count = 0;
	while (p != nullptr){

		string temp(p);
		if (temp[0] == ';') break; //we are reading a comment
		token.push_back(temp);
		count++;
		p = strtok(NULL, ",\t ");
	}
	delete[] cstr;
	return token;
}
bool isRegister(string str){
	if (str.length() != 2) return false;
	if (str == "PC" || str == "SL" || str == "SP" || str == "FP" || str == "SB")
		return true;
	if (str[0] != 'R') return false;
	int registerNum = atoi(&str[1]);
	if (registerNum<0 || registerNum>7) return false;
	return true;
}
bool isInteger(string str){
	if (!isdigit(str[0]) && str[0] != '-') return false;
	for (size_t i = 1; i !=str.length(); ++i){
		if (!isdigit(str[i])) return false;
	}
	return true;
}
bool isLabel(string str){
	if (isInteger(str)) return false;
	if (isRegister(str)) return false;
	return true;
}
int getRegister(string str){
	if (str[0] == 'R')
		return atoi(&(str[1]));
	else{
		if (str == "PC") return 8;
		if (str == "SL") return 9;
		if (str == "SP") return 10;
		if (str == "FP") return 11;
		if (str == "SB") return 12;
	}
}
bool checkTypeSyntax(vector<string> token,  int start){
	//start=0 if no label =1 if label
	//count: # of token in array, including the label
	//need type - value as an int or char(can be ascii value)
	if ((token.size() - start) != 2) return false;
	if (token[start] == ".INT"){
		if (!isInteger(token[start + 1])) return false;
		return true;
	}
	if (token[start] == ".BYT"){
		//CHECK if there is ' for a single character
		if (token[start + 1][0] == '\''){
			if (token[start + 1].length() != 3)
				return false;
			if (token[start + 1][2] = '\'')
				return true;
			else return false;
		}
		 //check if it is a correct ascii code
		size_t pos;
		if (!isInteger( token[start + 1])) return false;
		int temp = stoi(token[start + 1], &pos);
		if (temp<0 || temp>255) return false;
		return true;
	}
	return false;
}

bool generateByteCode(vector<string> token, char* instr, int instrPos, map<string, int>& symbol, int start){
	
	map<string, int> opcode;
	opcode["JMP"] = 1;
	opcode["JMR"] = 2;
	opcode["BNZ"] = 3;
	opcode["BGT"] = 4;
	opcode["BLT"] = 5;
	opcode["BRZ"] = 6;
	opcode["MOV"] = 7;
	opcode["LDA"] = 8;
	opcode["STR"] = 9;
	opcode["LDR"] = 10;
	opcode["STB"] = 11;
	opcode["LDB"] = 12;
	opcode["ADD"] = 13;
	opcode["ADI"] = 14;
	opcode["SUB"] = 15;
	opcode["MUL"] = 16;
	opcode["DIV"] = 17;
	opcode["AND"] = 18;
	opcode["OR"] = 19;
	opcode["CMP"] = 20;
	opcode["TRP"] = 0;
	map<string, int> indirectOpcode;
	indirectOpcode["STR"] = 21;
	indirectOpcode["LDR"] = 22;
	indirectOpcode["STB"] = 23;
	indirectOpcode["LDB"] = 24;

	//opcode register register
	if (token[start] == "ADD" || token[start] == "SUB" || token[start] == "DIV" || token[start] == "MUL" || token[start] == "MOV"|| 
		token[start]=="CMP"||token[start]=="AND" ||token[start]=="OR"){
		if ((token.size() - start) != 3) return false;
		if (!isRegister(token[start + 1])) return false;
		if (!isRegister(token[start + 2])) return false;
		int destinationRegister = getRegister(token[start + 1]);
		int sourceRegister = getRegister(token[start + 2]);
		memcpy(instr + instrPos, &opcode[token[start]], sizeof(int));
		instrPos += 4;
		memcpy(instr + instrPos, &destinationRegister, sizeof(int));
		instrPos += 4;
		memcpy(instr + instrPos, &sourceRegister, sizeof(int));

		return true;
	}
	//opcode register immediate
	if (token[start] == "ADI"){
		if ((token.size() - start) != 3) return false;
		if (!isRegister(token[start + 1])) return false;
		if (!isInteger(token[start + 2])) return false;
		int destinationRegister = getRegister(token[start + 1]);
		int immediate = stoi(token[start + 2]);
		memcpy(instr + instrPos, &opcode[token[start]], sizeof(int));
		instrPos += 4;
		memcpy(instr + instrPos, &destinationRegister, sizeof(int));
		instrPos += 4;
		memcpy(instr + instrPos, &immediate, sizeof(int));
		return true;
	}
	//opcode register label
	if (token[start] == "LDA" || token[start] == "BNZ" || token[start] == "BGT" || token[start] == "BLT" || token[start] == "BRZ"){
		if ((token.size() - start) != 3) return false;
		if (!isRegister(token[start + 1])) return false;
		if (!isLabel(token[start + 2])) return false;
		memcpy(instr + instrPos, &opcode[token[start]], sizeof(int));
		instrPos += 4;
		int destinationRegister = getRegister(token[start + 1]);
		memcpy(instr + instrPos, &destinationRegister, sizeof(int));
		instrPos += 4;
		//check that label is in symbol table
		auto it = symbol.find(token[start + 2]);
		if (it == symbol.end()) return false; //label not found in symbol table
		int adress = symbol[token[start + 2]];
		memcpy(instr + instrPos, &adress, sizeof(int));
		return true;
	}
	//opcode register register or register label
	if (token[start] == "LDB" || token[start] == "LDR" || token[start] == "STB" || token[start] == "STR"){
		if ((token.size() - start) != 3) return false;
		if (!isRegister(token[start + 1])) return false;
		if (!isRegister(token[start + 2]) && !isLabel(token[start + 2])) return false;
		if (isRegister(token[start + 2])){
			//indirect adressing
			memcpy(instr + instrPos, &indirectOpcode[token[start]], sizeof(int));
			instrPos += 4;
			int destinationRegister = getRegister(token[start + 1]);
			memcpy(instr + instrPos, &destinationRegister, sizeof(int));
			instrPos += 4;
			int sourceRegister = getRegister(token[start + 2]);
			memcpy(instr + instrPos, &sourceRegister, sizeof(int));
		}
		else{
			//direct adressing
			memcpy(instr + instrPos, &opcode[token[start]], sizeof(int));
			instrPos += 4;
			int destinationRegister = getRegister(token[start + 1]);
			memcpy(instr + instrPos, &destinationRegister, sizeof(int));
			instrPos += 4;
			//check that label is in symbol table
			auto it = symbol.find(token[start + 2]);
			if (it == symbol.end()) return false; //label not found in sybmbol table
			int adress = symbol[token[start + 2]];
			memcpy(instr + instrPos, &adress, sizeof(int));
		}
		return true;
	}
	//instruction label
	if (token[start] == "JMP"){
		if ((token.size() - start) != 2) return false;
		if (!isLabel(token[start + 1])) return false;
		//check that label is in symbol table
		auto it = symbol.find(token[start + 1]);
		if (it == symbol.end()) return false; //label not found in sybmbol table
		memcpy(instr + instrPos, &opcode[token[start]], sizeof(int));
		instrPos += 4;
		int adress = symbol[token[start + 1]];
		memcpy(instr + instrPos, &adress, sizeof(int));
		return true;
	}

	//instruction register
	if (token[start] == "JMR"){
		if ((token.size() - start) != 2) return false;
		if (!isRegister(token[start + 1])) return false;
		memcpy(instr + instrPos, &opcode[token[start]], sizeof(int));
		instrPos += 4;
		int destinationRegister = getRegister(token[start + 1]);
		memcpy(instr + instrPos, &destinationRegister, sizeof(int));
		instrPos += 4;
		return true;
	}

	if (token[start] == "TRP"){
		if ((token.size() - start) != 2) return false;
		if (!isInteger(token[start + 1])) return false;
		memcpy(instr + instrPos, &opcode[token[start]], sizeof(int));
		instrPos += 4;
		int code = atoi(&(token[start + 1][0]));;
		memcpy(instr + instrPos, &code, sizeof(int));
		return true;
	}
	return false;

}

bool loadData(vector<string> token, char* memory, int& memPos, int start){
	//2 data type 
	const int CHAR_SIZE = 1;
	const int INT_SIZE = 4;

	if (token[start] == ".BYT"){
		//insert data into memory
		if (token[start+1][0] == '\'')
			memory[memPos] = token[start+1][1];
		else
			memory[memPos] = stoi(token[start+1]);
		memPos += CHAR_SIZE;
		return true;
	}
	else if (token[start] == ".INT"){ //this is an int
		int value = stoi(token[start+1]);
		memcpy(memory + memPos, &value, sizeof(int));
		memPos += INT_SIZE;
		return true;
	}
	return false;
}
