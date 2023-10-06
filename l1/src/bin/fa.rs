use std::collections::{HashSet, HashMap};
use std::env;
use std::fs::{self, File};
use std::io::{self, BufRead};
use std::path::Path;

fn main() {
    let args: Vec<String> = env::args().collect();
    let pattern_path = args.get(1).unwrap();
    let txt_path = args.get(2).unwrap();
    let txt = fs::read_to_string(txt_path).expect("Should have been able to read the file");
    println!("{:?}", extract_input_alphabet(&txt));
    if let Ok(lines) = read_lines(pattern_path) {
        for line in lines {
            if let Ok(pattern_line) = line {
                let pattern = pattern_line.split("'").take(2).collect::<Vec<_>>()[1].to_string();
                println!("{}", &pattern);
                finite_automaton_matcher(&pattern, &txt);
            }
        }
    }
}

fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>>
where P: AsRef<Path>, {
    let file = File::open(filename)?;
    Ok(io::BufReader::new(file).lines())
}

fn extract_input_alphabet(txt: &String) -> HashSet<char> {
    let mut alphabet: HashSet<char> = HashSet::new();
    for ch in txt.chars() {
        alphabet.insert(ch);
    }
    alphabet
}

fn finite_automaton_matcher(pattern: &String, txt: &String) {
    let m = pattern.len();
    let n = txt.len();
    let tf = compute_transition_function();
    let mut state = 0;
    for i in 0..n {
        state = *tf[state].get(&pattern.chars().nth(i).unwrap()).unwrap();
        if state == m {
            println!("Found at {}", i-m+1);
        }
    }
}

fn next_state() {
    todo!()
}

fn compute_transition_function() -> Vec<HashMap<char, usize>>{
    todo!()
}