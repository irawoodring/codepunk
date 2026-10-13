# The Rail Yard

class Car:
    def __init__(self, cargo):
        self.cargo = cargo
        self.next = None


class Train:
    def __init__(self):
        self.head = None

    def attach(self, cargo):
        pass

    def couple_front(self, cargo):
        pass

    def __len__(self):
        pass

    def to_list(self):
        pass

    def detach(self, cargo):
        pass

    def reverse(self):
        pass
