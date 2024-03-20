def checkName(_name):
    answer = input("Is your name " + _name + "? ")

    if answer.lower() == "yes":
    # lower() turns the answer into lowercase
        print("Hello,", _name)
    else:
        print("We're sorry about that.")

checkName("Tommy")
