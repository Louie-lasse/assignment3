INSERT INTO Departments VALUES ('Dep1','D1');

INSERT INTO Programs VALUES ('Prog1','P1'),
                            ('Prog2','P2');

INSERT INTO ProgramDepartments VALUES ('Prog1','Dep1'),
                                      ('Prog2','Dep1');

INSERT INTO Branches VALUES ('B1','Prog1'),
                            ('B2','Prog1'),
                            ('B1','Prog2');

INSERT INTO Students VALUES ('1111111111','N1','ls1','Prog1'),
                            ('2222222222','N2','ls2','Prog1'),
                            ('3333333333','N3','ls3','Prog2'),
                            ('4444444444','N4','ls4','Prog1'),
                            ('5555555555','Nx','ls5','Prog2'),
                            ('6666666666','Nx','ls6','Prog2');

INSERT INTO Courses VALUES ('CCC111','C1',22.5,'Dep1'),
                           ('CCC222','C2',20,'Dep1'),
                           ('CCC333','C3',30,'Dep1'),
                           ('CCC444','C4',60,'Dep1'),
                           ('CCC555','C5',50,'Dep1');

INSERT INTO LimitedCourses VALUES ('CCC222',1),
                                  ('CCC333',2);

INSERT INTO Classified VALUES ('math','CCC333'),
                              ('math','CCC444'),
                              ('research','CCC444'),
                              ('seminar','CCC444');

INSERT INTO StudentBranches VALUES ('2222222222','B1','Prog1'),
                                   ('3333333333','B1','Prog2'),
                                   ('4444444444','B1','Prog1'),
                                   ('5555555555','B1','Prog2');

INSERT INTO MandatoryProgram VALUES ('CCC111','Prog1');

INSERT INTO MandatoryBranch VALUES ('CCC333', 'B1', 'Prog1'),
                                   ('CCC444', 'B1', 'Prog2');

INSERT INTO RecommendedBranch VALUES ('CCC222', 'B1', 'Prog1'),
                                     ('CCC333', 'B1', 'Prog2');

INSERT INTO Registered VALUES ('1111111111','CCC111'),
                              ('1111111111','CCC222'),
                              ('1111111111','CCC333'),
                              ('2222222222','CCC222'),
                              ('5555555555','CCC222'),
                              ('5555555555','CCC333');

INSERT INTO Taken VALUES('4444444444','CCC111','5'),
                        ('4444444444','CCC222','5'),
                        ('4444444444','CCC333','5'),
                        ('4444444444','CCC444','5'),
                        ('5555555555','CCC111','5'),
                        ('5555555555','CCC222','4'),
                        ('5555555555','CCC444','3'),
                        ('2222222222','CCC111','U'),
                        ('2222222222','CCC222','U'),
                        ('2222222222','CCC444','U');


INSERT INTO WaitingList VALUES('3333333333','CCC222'),
                              ('3333333333','CCC333'), 
                              ('2222222222','CCC333');
