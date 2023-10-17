use std::env;
use std::fs;

use l1::*;

fn main() {
    let args: Vec<String> = env::args().collect();
    let pattern_path = args.get(1).unwrap();
    let txt_path = args.get(2).unwrap();
    let txt = fs::read_to_string(txt_path).expect("Should have been able to read the file");
    if let Ok(lines) = read_lines(pattern_path) {
        for line in lines {
            if let Ok(pattern_line) = line {
                let pattern = pattern_line.split("'").take(2).collect::<Vec<_>>()[1].to_string();
                println!("{}", &pattern);
                println!("{:?}", knuth_morri_pratt_matcher(&pattern, &txt));
            }
        }
    }
}

fn knuth_morri_pratt_matcher(pattern: &String, txt: &String) -> Vec<usize> {
    let pattern: Vec<char> = pattern.chars().collect();
    let txt: Vec<char> = txt.chars().collect();
    
    let n = txt.len();
    let m = pattern.len();

    let pi = compute_prefix_function(&pattern, m);

    let mut pattern_idx = 0;
    let mut txt_idx = 0;

    let mut res = Vec::new();

    while (n - txt_idx) >= (m - pattern_idx) {
        if pattern[pattern_idx] == txt[txt_idx] {
            // pattern i txt zgadza się
            txt_idx += 1;
            pattern_idx += 1;
        }
        if pattern_idx == m {
            // znaleziono pattern
            res.push(txt_idx - pattern_idx);
            pattern_idx = pi[pattern_idx - 1];
        } else if txt_idx < n && pattern[pattern_idx] != txt[txt_idx] {
            // mismatch
            if pattern_idx != 0 {
                // updateujemy nasze okienko
                pattern_idx = pi[pattern_idx - 1];
            } else {
                // jeśli nasze onko jest na początku
                txt_idx += 1;
            }
        }
    }
    res
}

fn compute_prefix_function(pattern: &Vec<char>, m: usize) -> Vec<usize> {
    let mut pi = vec![0; m];

    let mut l = 0;
    let mut idx = 1;
    
    while idx < m {
        if pattern[idx] == pattern[l] {
            // jeśli matchuje progresujemy
            l += 1;
            pi[idx] = l;
            idx += 1;
        } else {
            // nie matchuje rozwzamy przypadki
            if l != 0 {
                // długość prefix != 0 idziemy do tyłu
                l = pi[l - 1];
            } else {
                // idziemy dalej z 0
                pi[idx] = 0;
                idx += 1;
            }
        }
    }
    pi
}
