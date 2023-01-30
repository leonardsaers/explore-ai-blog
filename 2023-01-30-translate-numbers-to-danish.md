# Translate number into Danish

A common coding challenge in Sweden is to construct a program that takes a number and returns the spelling of that number but in danish.

This is actual a good challenge to an AI that both understand how to code but also concepts which it has learned from reading text.

To start with a simple challenge, I asked it produce code that translates into English

> [me] - Can you give me function in java code that take a number as input between 0 and 100, and returns the number as it would be spelled in English

> [ChatGPT-3] - Here's a Java function that takes an integer between 0 and 100 as input and returns the number as it would be spelled in English:

``` java
public static String numberToWords(int num) {
    if (num == 0) return "zero";
    if (num < 0 || num > 100) return "Invalid input";

    String[] belowTen = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine"};
    String[] belowTwenty = {"ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"};
    String[] tens = {"twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"};

    if (num < 10) return belowTen[num - 1];
    if (num < 20) return belowTwenty[num - 10];
    if (num == 100) return "one hundred";

    String result = tens[(num / 10) - 2];
    if (num % 10 != 0) result += "-" + belowTen[num % 10 - 1];

    return result;
}
```
The suggested code by ChatGPT-3 does the job fine, it also checks for invalid input.

The next step is to find out if it also can handle danish.

> [me] Can you give me function in java code that take a number as input between 0 and 100, and returns the number as it would be spelled in English

> [ChatGPT-3] Here's a Java function that takes a number between 0 and 100 as input and returns its English spelling:

``` java
public static String numberToWords(int num) {
    if (num == 0) return "zero";
    if (num < 0 || num > 100) return "Invalid input";

    String[] belowTen = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine"};
    String[] belowTwenty = {"ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"};
    String[] tens = {"twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"};

    if (num < 10) return belowTen[num - 1];
    if (num < 20) return belowTwenty[num - 10];
    if (num == 100) return "one hundred";

    String result = tens[(num / 10) - 2];
    if (num % 10 != 0) result += "-" + belowTen[num % 10 - 1];

    return result;
}
```

It's the same code but translated to danish. However, it does not return the danish spelling for all numbers between 0 and 100.

I asked ChatGPT-3 several times, and it provided me with different variants of code that all worked when translating to English.

It seems that ChatGPT-3 crashes if it's first question is to create the method for Danish instead of English. So a guess is that it can solve the problem for English and than it simply tries to directly translate the strings in the suggested code to Danish.

Once again an impressive result by ChatGPT-3.
