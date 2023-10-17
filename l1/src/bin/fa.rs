use std::collections::{HashSet, HashMap};
use std::env;
use std::fs;

use l1::*;

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
                println!("{:?}", finite_automaton_matcher(&pattern, &txt));
            }
        }
    }
}

fn extract_input_alphabet(txt: &String) -> HashSet<char> {
    let mut alphabet: HashSet<char> = HashSet::new();
    for ch in txt.chars() {
        alphabet.insert(ch);
    }
    alphabet
}

fn finite_automaton_matcher(pattern: &String, txt: &String) -> Vec<usize> {
    let m = pattern.chars().collect::<Vec<_>>().len();
    let n = txt.chars().collect::<Vec<_>>().len();
    let tf = compute_transition_function(m, extract_input_alphabet(txt), pattern);
    
    let mut res = Vec::new();
    let mut state = 0;
    for i in 0..n {
        state = *tf[state].get(&txt.chars().nth(i).unwrap()).unwrap();
        if state == m {
            res.push(i-m+1);
        }
    }
    res
}

fn compute_transition_function(m: usize, alphabet: HashSet<char>, pattern: &String) -> Vec<HashMap<char, usize>>{
    let mut transition_function: Vec<HashMap<char, usize>> = vec![HashMap::new(); m+1];
    for q in 0..=m {
        for ch in &alphabet {
            let mut k = m.min(q+1);
            while !&format!("{}{}", pattern.chars().take(q).collect::<String>(), ch).ends_with(&pattern.chars().take(k).collect::<String>()){
                k -= 1;
            }
            transition_function[q].insert(*ch, k);
        }
    }
    transition_function
}
