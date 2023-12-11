# importing libraries
import ply.yacc as yacc
import ply.lex as lex
from sys import stdin

# our field size, prime btw
P = 1234577

def flatten(x: int) -> int:
    return ((x % P) + P) % P
def flatten_exp(x: int) -> int:
    return ((x % (P-1)) + (P-1)) % (P-1)


def multiply(x: int, y: int) -> int:
    ''' Multiplication inside finite field '''
    output = flatten(x)
    for i in range(1, y):
        output += x
        output = flatten(output)
    return output

def multiply_exp(x: int, y: int) -> int:
    ''' Multiplication inside finite field '''
    output = flatten_exp(x)
    for i in range(1, y):
        output += x
        output = flatten_exp(output)
    return output

def inverse(a: int) -> int:
    ''' Extended Euclidean Algorithm for finding modular inverse '''
    m = P
    x = 1
    y = 0

    while a > 1:
        quotient = a // m
        t = m

        m = a % m
        a = t
        t = y

        y = x - quotient * y
        x = t

    if x < 0:
        x += P

    return x

def inverse_exp(a: int) -> int:
    ''' Extended Euclidean Algorithm for finding modular inverse '''
    m = (P-1)
    x = 1
    y = 0

    while a > 1:
        try:
            quotient = a // m
        except:
            return
        t = m

        m = a % m
        a = t
        t = y

        y = x - quotient * y
        x = t

    if x < 0:
        x += (P-1)

    return x

def print_(*x) -> None:
    ''' Print without Newline '''
    print(*x, end='')

# Token declarations
tokens = (
    'ADD', 'SUB', 'MUL', 'DIV', 'POW',
    'LPR', 'RPR',
    'NUM',
    'COM'
)

# all the token definitions
t_COM = r'\#.*'
t_ADD = r'\+'
t_MUL = r'\*'
t_DIV = r'\/'
t_POW = r'\^'
t_LPR = r'\('
t_RPR = r'\)'
t_SUB = r'-'

# number string to int
def t_NUM(t):
    r'[0-9]+'
    t.value = int(t.value)
    return t


# ignore blanks
t_ignore = ' \t'


def t_newline(t):
    r'\n+'
    t.lexer.lineno += t.value.count('\n')


def t_error(t):
    print(f'\ninvalid character: {t.value[0]!r}')
    t.lexer.skip(1)


# build the lexer
lex.lex()

# precedence rules for the arithmetic operators
precedence = (
    ('left', 'ADD', 'SUB'),
    ('left', 'MUL', 'DIV'),
    ('right', 'NEG', 'POW')
)


def p_STAR_EXPR(p):
    'STAR : EXPR'
    print()
    print('Wynik: ', p[1])


# allow comments
def p_STAR_COM(p):
    'STAR : COM'
    pass


def p_NUMR(p):
    'NUMR : NUM'
    p[0] = flatten(p[1])
    print_(p[0], '')


def p_NUMR_NEG(p):
    'NUMR : SUB NUM %prec NEG'
    p[0] = flatten(0 - flatten(p[2]))
    print_(p[0], '')

def p_EXPR_NEG(p):
    'EXPR : SUB EXPR %prec NEG'
    p[0] = flatten(0 - flatten(p[2]))
    print_("~", '')

def p_EXPR_ADD(p):
    'EXPR : EXPR ADD EXPR'
    p[0] = flatten(flatten(p[1]) + flatten(p[3]))
    print_('+ ')


def p_EXPR_SUB(p):
    'EXPR : EXPR SUB EXPR'
    p[0] = flatten(flatten(p[1]) - flatten(p[3]))
    print_('- ')


def p_EXPR_MUL(p):
    'EXPR : EXPR MUL EXPR'
    p[0] = multiply(p[1], p[3])
    print_('* ')


def p_EXPR_DIV(p):
    'EXPR : EXPR DIV EXPR'
    x = p[1]
    y = p[3]
    if y == 0:
        print_('/ ')
        print_('\nError: dzielenie przez 0')
        return
    p[0] = flatten(multiply(x, inverse(y)))
    print_('/ ')

def p_EXPR_POW(p):
    'EXPR : EXPR POW EXPO'
    x = p[1]
    y = p[3]
    output = 1
    if y is None :
        return
    for i in range(0, y):
        output *= x
        output = flatten(output)
    p[0] = output
    print_('^ ')


def p_EXPR_PRS(p):
    'EXPR : LPR EXPR RPR'
    p[0] = p[2]


def p_EXPR_NUM(p):
    'EXPR : NUMR'
    p[0] = p[1]

# Exponent clalc

def p_EXPONUMR(p):
    'EXPONUMR : NUM'
    p[0] = flatten_exp(p[1])
    print_(p[0], '')


def p_EXPONUMR_NEG(p):
    'EXPONUMR : SUB NUM %prec NEG'
    p[0] = flatten_exp(0 - flatten_exp(p[2]))
    print_(p[0], '')

def p_EXPO_NEG(p):
    'EXPO : SUB EXPO %prec NEG'
    p[0] = flatten_exp(0 - flatten_exp(p[2]))
    print_("~", '')

def p_EXPO_ADD(p):
    'EXPO : EXPO ADD EXPO'
    p[0] = flatten_exp(flatten_exp(p[1]) + flatten_exp(p[3]))
    print_('+ ')


def p_EXPO_SUB(p):
    'EXPO : EXPO SUB EXPO'
    p[0] = flatten_exp(flatten_exp(p[1]) - flatten_exp(p[3]))
    print_('- ')


def p_EXPO_MUL(p):
    'EXPO : EXPO MUL EXPO'
    p[0] = multiply_exp(p[1], p[3])
    print_('* ')


def p_EXPO_DIV(p):
    'EXPO : EXPO DIV EXPO'
    x = p[1]
    y = p[3]
    if y == 0:
        print_('/ ')
        print_('\nError: dzielenie przez 0')
        return
    r = inverse_exp(y)
    if r is None :
        print_(f'\nError: {y} nie odwracalne w eksponencie')
        return
    p[0] = flatten_exp(multiply_exp(x, inverse_exp(y)))
    print_('/ ')

def p_EXPO_PRS(p):
    'EXPO : LPR EXPO RPR'
    p[0] = p[2]


def p_EXPO_NUM(p):
    'EXPO : EXPONUMR'
    p[0] = p[1]


def p_error(p):
    if p != None:
        print(f'\nsyntax error: ‘{p.value}’')
    else:
        print(f'syntax error')


yacc.yacc()

acc = ''
for line in stdin:
    if line[-2] == '\\':
        # accumulate for later evaluation
        acc += line[:-2]
    elif acc != '':
        acc += line
        # evaluate a concatenation of multiple lines
        yacc.parse(acc)
        # empty the accumulator
        acc = ''
    else:
        # otherwise parse one given line
        yacc.parse(line)