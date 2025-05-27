import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ConnectFormComponent } from './connect-form.component';

describe('ConnectFormComponent', () => {
  let component: ConnectFormComponent;
  let fixture: ComponentFixture<ConnectFormComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ConnectFormComponent]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(ConnectFormComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
