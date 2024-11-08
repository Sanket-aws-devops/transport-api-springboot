package com.transfort.management.transport.entities;

import javax.persistence.*;
import java.sql.Timestamp;

@Entity
@Table(name = "route_user")
public class RouteUserEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "routeid", nullable = false)
    private RouteEntity route;

    @Column(name = "userid", nullable = false)
    private Long userId;

    @Column(name = "parentid", nullable = false)
    private Long parentId;

    @Column(name = "status", columnDefinition = "boolean default false")
    private Boolean status;

    @Column(name = "created_on")
    private Timestamp createdOn;

    @Column(name = "modified_on")
    private Timestamp modifiedOn;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public RouteEntity getRoute() {
		return route;
	}

	public void setRoute(RouteEntity route) {
		this.route = route;
	}

	public Long getUserId() {
		return userId;
	}

	public void setUserId(Long userId) {
		this.userId = userId;
	}

	public Long getParentId() {
		return parentId;
	}

	public void setParentId(Long parentId) {
		this.parentId = parentId;
	}

	public Boolean getStatus() {
		return status;
	}

	public void setStatus(Boolean status) {
		this.status = status;
	}

	public Timestamp getCreatedOn() {
		return createdOn;
	}

	public void setCreatedOn(Timestamp createdOn) {
		this.createdOn = createdOn;
	}

	public Timestamp getModifiedOn() {
		return modifiedOn;
	}

	public void setModifiedOn(Timestamp modifiedOn) {
		this.modifiedOn = modifiedOn;
	}
    
}
